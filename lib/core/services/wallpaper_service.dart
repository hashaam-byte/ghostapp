// lib/core/services/wallpaper_service.dart - FIXED VERSION
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import 'storage_service.dart';

class WallpaperService {
  static const MethodChannel _channel = MethodChannel('ghostx/wallpaper');

  // Request wallpaper permission before extraction
  static Future<bool> _requestPermission() async {
    try {
      // Check Android version
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Request permission
      final status = await Permission.storage.request();
      
      if (status.isDenied) {
        debugPrint('⚠️ Wallpaper permission denied by user');
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('⚠️ Wallpaper permission permanently denied - opening settings');
        await openAppSettings();
        return false;
      }

      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Permission request error: $e');
      return false;
    }
  }

  // Extract wallpaper and generate adaptive colors
  static Future<WallpaperColors> extractWallpaperColors() async {
    try {
      // Request permission first
      final hasPermission = await _requestPermission();
      
      if (!hasPermission) {
        debugPrint('ℹ️ Using default colors (no wallpaper permission)');
        return WallpaperColors.defaultColors();
      }

      // Try to get wallpaper from Android
      final Uint8List? wallpaperBytes = await _getWallpaperBytes();
      
      if (wallpaperBytes != null) {
        debugPrint('✅ Wallpaper extracted successfully');
        return await _generatePaletteFromBytes(wallpaperBytes);
      } else {
        debugPrint('ℹ️ No wallpaper data available');
        return WallpaperColors.defaultColors();
      }
    } catch (e) {
      debugPrint('⚠️ Wallpaper extraction failed: $e');
      return WallpaperColors.defaultColors();
    }
  }

  // Get wallpaper bytes from Android
  static Future<Uint8List?> _getWallpaperBytes() async {
    try {
      final Uint8List? bytes = await _channel.invokeMethod('getWallpaper');
      return bytes;
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED')) {
        debugPrint('⚠️ Wallpaper permission denied - using defaults');
      } else {
        debugPrint('❌ Failed to get wallpaper: $e');
      }
      return null;
    }
  }

  // Generate color palette from image bytes
  static Future<WallpaperColors> _generatePaletteFromBytes(
    Uint8List bytes,
  ) async {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        debugPrint('⚠️ Failed to decode wallpaper image');
        return WallpaperColors.defaultColors();
      }

      // Convert to Flutter image
      final ui.Image flutterImage = await _convertToFlutterImage(image);

      // Generate palette
      final PaletteGenerator generator = await PaletteGenerator.fromImage(
        flutterImage,
        maximumColorCount: 16,
      );

      // Extract colors
      final primary = generator.dominantColor?.color ?? AppTheme.primaryPurple;
      final vibrant = generator.vibrantColor?.color ?? AppTheme.accentCyan;
      final muted = generator.mutedColor?.color ?? AppTheme.accentPink;
      
      final colors = WallpaperColors(
        primary: primary,
        accent: vibrant,
        secondary: muted,
        ghostTint: _generateGhostTint(primary),
        auraStart: primary,
        auraEnd: vibrant,
        particleColor: _generateParticleColor(vibrant, muted),
      );

      // Save to storage
      await _saveColors(colors);

      debugPrint('✅ Wallpaper colors extracted and applied');
      return colors;
    } catch (e) {
      debugPrint('❌ Palette generation failed: $e');
      return WallpaperColors.defaultColors();
    }
  }

  // Convert img.Image to ui.Image
  static Future<ui.Image> _convertToFlutterImage(img.Image image) async {
    final resized = img.copyResize(image, width: 200); // Optimize for speed
    final bytes = img.encodePng(resized);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // Generate ghost tint from primary color
  static Color _generateGhostTint(Color primary) {
    // Mix primary with white for ghost body
    return Color.lerp(Colors.white, primary, 0.15) ?? Colors.white;
  }

  // Generate particle color
  static Color _generateParticleColor(Color vibrant, Color muted) {
    return Color.lerp(vibrant, muted, 0.5) ?? vibrant;
  }

  // Save colors to storage
  static Future<void> _saveColors(WallpaperColors colors) async {
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

  // Load saved colors
  static Future<WallpaperColors?> loadSavedColors() async {
    final saved = await StorageService.getWallpaperColors();
    if (saved != null) {
      return WallpaperColors(
        primary: Color(saved['primary']),
        accent: Color(saved['accent']),
        secondary: Color(saved['secondary']),
        ghostTint: Color(saved['ghostTint']),
        auraStart: Color(saved['auraStart']),
        auraEnd: Color(saved['auraEnd']),
        particleColor: Color(saved['particleColor']),
      );
    }
    return null;
  }

  // Apply colors to app theme
  static void applyColors(WallpaperColors colors) {
    AppColors.ghostTint = colors.ghostTint;
    AppColors.auraStart = colors.auraStart;
    AppColors.auraEnd = colors.auraEnd;
    AppColors.particleColor = colors.particleColor;
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