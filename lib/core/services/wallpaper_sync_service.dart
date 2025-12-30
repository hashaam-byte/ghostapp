// lib/core/services/wallpaper_sync_service.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image/image.dart' as img;
import '../theme/app_theme.dart';
import 'storage_service.dart';

class WallpaperSyncService extends ChangeNotifier {
  static final WallpaperSyncService _instance = WallpaperSyncService._internal();
  factory WallpaperSyncService() => _instance;
  WallpaperSyncService._internal();

  static const MethodChannel _channel = MethodChannel('ghostx/wallpaper');

  WallpaperColors? _currentColors;
  Uint8List? _wallpaperBytes;
  bool _isEnabled = true;
  bool _isLoading = false;

  WallpaperColors? get currentColors => _currentColors;
  Uint8List? get wallpaperBytes => _wallpaperBytes;
  bool get isEnabled => _isEnabled;
  bool get isLoading => _isLoading;

  // Initialize on app start
  Future<void> initialize() async {
    await _loadSavedSettings();
    if (_isEnabled) {
      await extractAndApply();
    }
  }

  // Extract wallpaper and generate adaptive colors
  Future<void> extractAndApply() async {
    if (!_isEnabled) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Try to get wallpaper from Android
      final bytes = await _getWallpaperBytes();
      
      if (bytes != null) {
        _wallpaperBytes = bytes;
        final colors = await _generatePaletteFromBytes(bytes);
        await _applyColors(colors);
      } else {
        // Fallback to default
        await _applyColors(WallpaperColors.defaultColors());
      }
    } catch (e) {
      debugPrint('Wallpaper extraction failed: $e');
      await _applyColors(WallpaperColors.defaultColors());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get wallpaper bytes from Android native
  Future<Uint8List?> _getWallpaperBytes() async {
    try {
      final Uint8List? bytes = await _channel.invokeMethod('getWallpaper');
      return bytes;
    } catch (e) {
      debugPrint('Failed to get wallpaper: $e');
      return null;
    }
  }

  // Generate color palette from image bytes
  Future<WallpaperColors> _generatePaletteFromBytes(Uint8List bytes) async {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) return WallpaperColors.defaultColors();

      // Resize for faster processing
      final resized = img.copyResize(image, width: 200);
      
      // Convert to Flutter image
      final pngBytes = img.encodePng(resized);
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      final flutterImage = frame.image;

      // Generate palette
      final generator = await PaletteGenerator.fromImage(
        flutterImage,
        maximumColorCount: 16,
      );

      // Extract colors
      final primary = generator.dominantColor?.color ?? AppTheme.primaryPurple;
      final vibrant = generator.vibrantColor?.color ?? AppTheme.accentCyan;
      final muted = generator.mutedColor?.color ?? AppTheme.accentPink;
      
      return WallpaperColors(
        primary: primary,
        accent: vibrant,
        secondary: muted,
        ghostTint: _generateGhostTint(primary),
        auraStart: primary,
        auraEnd: vibrant,
        particleColor: _generateParticleColor(vibrant, muted),
      );
    } catch (e) {
      debugPrint('Palette generation failed: $e');
      return WallpaperColors.defaultColors();
    }
  }

  // Generate ghost tint from primary color
  Color _generateGhostTint(Color primary) {
    return Color.lerp(Colors.white, primary, 0.15) ?? Colors.white;
  }

  // Generate particle color
  Color _generateParticleColor(Color vibrant, Color muted) {
    return Color.lerp(vibrant, muted, 0.5) ?? vibrant;
  }

  // Apply colors to app theme
  Future<void> _applyColors(WallpaperColors colors) async {
    _currentColors = colors;
    AppColors.ghostTint = colors.ghostTint;
    AppColors.auraStart = colors.auraStart;
    AppColors.auraEnd = colors.auraEnd;
    AppColors.particleColor = colors.particleColor;
    
    await _saveColors(colors);
    notifyListeners();
  }

  // Save colors to storage
  Future<void> _saveColors(WallpaperColors colors) async {
    await StorageService.saveWallpaperColors({
      'primary': colors.primary.value,
      'accent': colors.accent.value,
      'secondary': colors.secondary.value,
      'ghostTint': colors.ghostTint.value,
      'auraStart': colors.auraStart.value,
      'auraEnd': colors.auraEnd.value,
      'particleColor': colors.particleColor.value,
    });
  }

  // Load saved settings
  Future<void> _loadSavedSettings() async {
    final saved = await StorageService.getWallpaperColors();
    if (saved != null) {
      _currentColors = WallpaperColors(
        primary: Color(saved['primary']),
        accent: Color(saved['accent']),
        secondary: Color(saved['secondary']),
        ghostTint: Color(saved['ghostTint']),
        auraStart: Color(saved['auraStart']),
        auraEnd: Color(saved['auraEnd']),
        particleColor: Color(saved['particleColor']),
      );
      _applyColors(_currentColors!);
    }
  }

  // Toggle wallpaper sync
  void toggleSync(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
    if (enabled) {
      extractAndApply();
    } else {
      _applyColors(WallpaperColors.defaultColors());
    }
  }

  // Manual color override
  void setManualColors(WallpaperColors colors) {
    _isEnabled = false;
    _applyColors(colors);
  }
}

class WallpaperColors {
  final Color primary;
  final Color accent;
  final Color secondary;
  final Color ghostTint;
  final Color auraStart;
  final Color auraEnd;
  final Color particleColor;

  WallpaperColors({
    required this.primary,
    required this.accent,
    required this.secondary,
    required this.ghostTint,
    required this.auraStart,
    required this.auraEnd,
    required this.particleColor,
  });

  factory WallpaperColors.defaultColors() {
    return WallpaperColors(
      primary: AppTheme.primaryPurple,
      accent: AppTheme.accentCyan,
      secondary: AppTheme.accentPink,
      ghostTint: AppTheme.ghostWhite,
      auraStart: AppTheme.primaryPurple,
      auraEnd: AppTheme.accentCyan,
      particleColor: AppTheme.accentPink,
    );
  }
}