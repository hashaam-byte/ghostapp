// lib/core/services/wallpaper_sync_service.dart - FIXED FOR YOUR STORAGE
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'storage_service.dart';

class WallpaperColors {
  final Color primary;
  final Color accent;
  final Color auraStart;
  final Color auraEnd;
  final Color ghostTint;
  final Color particleColor;

  WallpaperColors({
    required this.primary,
    required this.accent,
    required this.auraStart,
    required this.auraEnd,
    Color? ghostTint,
    Color? particleColor,
  }) : ghostTint = ghostTint ?? primary.withOpacity(0.3),
       particleColor = particleColor ?? accent.withOpacity(0.5);

  Map<String, dynamic> toJson() => {
    'primary': primary.value,
    'accent': accent.value,
    'auraStart': auraStart.value,
    'auraEnd': auraEnd.value,
    'ghostTint': ghostTint.value,
    'particleColor': particleColor.value,
  };

  factory WallpaperColors.fromJson(Map<String, dynamic> json) {
    return WallpaperColors(
      primary: Color(json['primary']),
      accent: Color(json['accent']),
      auraStart: Color(json['auraStart']),
      auraEnd: Color(json['auraEnd']),
      ghostTint: json['ghostTint'] != null ? Color(json['ghostTint']) : null,
      particleColor: json['particleColor'] != null ? Color(json['particleColor']) : null,
    );
  }

  factory WallpaperColors.defaultColors() {
    return WallpaperColors(
      primary: AppTheme.primaryPurple,
      accent: AppTheme.accentCyan,
      auraStart: AppColors.auraStart,
      auraEnd: AppColors.auraEnd,
    );
  }
}

class WallpaperSyncService extends ChangeNotifier {
  static const platform = MethodChannel('ghostx/wallpaper');
  static const String _wallpaperBytesKey = 'wallpaper_bytes_base64';
  
  Uint8List? _wallpaperBytes;
  WallpaperColors? _currentColors;
  bool _isEnabled = true;
  bool _hasPermission = false;
  bool _isLoading = false;

  Uint8List? get wallpaperBytes => _wallpaperBytes;
  WallpaperColors? get currentColors => _currentColors;
  bool get isEnabled => _isEnabled;
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    debugPrint('🎨 Initializing wallpaper colors...');
    
    // Step 1: Load saved data immediately (instant UI)
    await _loadSavedData();
    
    // Step 2: Check and request permission (this shows dialog on Android 6-12)
    debugPrint('📋 Requesting wallpaper permission...');
    _hasPermission = await _requestPermission();
    
    if (_hasPermission) {
      debugPrint('✅ Wallpaper permission granted - extracting colors');
      await _extractWallpaperColors();
    } else {
      debugPrint('! Wallpaper permission denied by user');
      debugPrint('ℹ️ Using default colors (no wallpaper permission)');
      _useDefaultColors();
    }
    
    notifyListeners();
  }

  Future<bool> _requestPermission() async {
    try {
      // First check using the native channel
      final bool? hasNativePermission = await platform.invokeMethod('checkWallpaperPermission');
      
      if (hasNativePermission == true) {
        debugPrint('✅ Permission already granted (Android 13+ or previously granted)');
        return true;
      }

      // For Android 6-12, request permission using native dialog
      debugPrint('📱 Requesting permission (Android 6-12)...');
      final bool? permissionGranted = await platform.invokeMethod('requestWallpaperPermission');
      
      if (permissionGranted == true) {
        debugPrint('✅ User granted wallpaper permission');
        return true;
      } else {
        debugPrint('! User denied wallpaper permission');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Permission request error: $e');
      // Try fallback with permission_handler package
      return await _requestPermissionFallback();
    }
  }

  Future<bool> _requestPermissionFallback() async {
    try {
      // Android 13+ needs photos permission
      if (await Permission.photos.request().isGranted) {
        return true;
      }
      
      // Android 6-12 needs storage permission
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('⚠️ Fallback permission failed: $e');
      return false;
    }
  }

  Future<void> _extractWallpaperColors() async {
    if (!_hasPermission) {
      debugPrint('⚠️ Cannot extract wallpaper - no permission');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get wallpaper from native side
      final Uint8List? wallpaper = await platform.invokeMethod('getWallpaper');
      
      if (wallpaper == null || wallpaper.isEmpty) {
        debugPrint('ℹ️ No wallpaper data received');
        _useDefaultColors();
        return;
      }

      _wallpaperBytes = wallpaper;
      
      // Extract colors
      final image = img.decodeImage(wallpaper);
      if (image != null) {
        final colors = _extractColorsFromImage(image);
        _currentColors = colors;
        
        // Save to storage
        await _saveColors(colors);
        await _saveWallpaper(wallpaper);
        
        debugPrint('✅ Wallpaper colors extracted and saved');
      } else {
        debugPrint('⚠️ Failed to decode wallpaper image');
        _useDefaultColors();
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to get wallpaper: ${e.code} - ${e.message}');
      
      if (e.code == 'PERMISSION_DENIED') {
        _hasPermission = false;
        debugPrint('ℹ️ Using default colors (no wallpaper permission)');
      }
      
      _useDefaultColors();
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      _useDefaultColors();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useDefaultColors() {
    _currentColors = WallpaperColors.defaultColors();
    notifyListeners();
  }

  WallpaperColors _extractColorsFromImage(img.Image image) {
    // Resize for faster processing
    final resized = img.copyResize(image, width: 100);
    
    // Extract dominant colors
    final colors = <Color>[];
    for (int y = 0; y < resized.height; y += 5) {
      for (int x = 0; x < resized.width; x += 5) {
        final pixel = resized.getPixel(x, y);
        colors.add(Color.fromARGB(255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()));
      }
    }

    // Sort by vibrance
    colors.sort((a, b) => _colorVibrance(b).compareTo(_colorVibrance(a)));
    
    final primary = colors.isNotEmpty ? colors[0] : AppTheme.primaryPurple;
    final accent = colors.length > 1 ? colors[1] : AppTheme.accentCyan;
    
    return WallpaperColors(
      primary: primary,
      accent: accent,
      auraStart: primary.withOpacity(0.6),
      auraEnd: accent.withOpacity(0.4),
      ghostTint: primary.withOpacity(0.3),
      particleColor: accent.withOpacity(0.5),
    );
  }

  double _colorVibrance(Color color) {
    final max = [color.red, color.green, color.blue].reduce((a, b) => a > b ? a : b);
    final min = [color.red, color.green, color.blue].reduce((a, b) => a < b ? a : b);
    return (max - min) / 255.0;
  }

  Future<void> _loadSavedData() async {
    try {
      // Load saved colors
      final savedColors = await StorageService.getWallpaperColors();
      if (savedColors != null) {
        _currentColors = WallpaperColors.fromJson(savedColors);
        debugPrint('✅ Loaded saved wallpaper colors');
      }

      // Load saved wallpaper bytes (stored as base64 to work with SharedPreferences)
      try {
        final base64String = await _getWallpaperBytesFromStorage();
        if (base64String != null && base64String.isNotEmpty) {
          _wallpaperBytes = base64Decode(base64String);
          debugPrint('✅ Loaded saved wallpaper image');
        }
      } catch (e) {
        debugPrint('ℹ️ No saved wallpaper bytes found: $e');
      }

      if (_currentColors == null) {
        _useDefaultColors();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load saved data: $e');
      _useDefaultColors();
    }
  }

  Future<void> _saveColors(WallpaperColors colors) async {
    await StorageService.saveWallpaperColors(colors.toJson());
  }

  Future<void> _saveWallpaper(Uint8List bytes) async {
    try {
      // Convert to base64 for SharedPreferences storage
      final base64String = base64Encode(bytes);
      await _saveWallpaperBytesToStorage(base64String);
      debugPrint('✅ Wallpaper bytes saved');
    } catch (e) {
      debugPrint('⚠️ Failed to save wallpaper bytes: $e');
    }
  }

  // Helper methods for wallpaper bytes storage (using SharedPreferences directly)
  Future<String?> _getWallpaperBytesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_wallpaperBytesKey);
    } catch (e) {
      debugPrint('⚠️ Failed to get wallpaper bytes: $e');
      return null;
    }
  }

  Future<void> _saveWallpaperBytesToStorage(String base64String) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_wallpaperBytesKey, base64String);
    } catch (e) {
      debugPrint('⚠️ Failed to save wallpaper bytes: $e');
    }
  }

  // Public methods for UI
  Future<void> requestPermission() async {
    _hasPermission = await _requestPermission();
    if (_hasPermission) {
      await _extractWallpaperColors();
    }
    notifyListeners();
  }

  Future<void> extractAndApply() async {
    if (!_hasPermission) {
      debugPrint('⚠️ Cannot extract - requesting permission first');
      await requestPermission();
      return;
    }
    await _extractWallpaperColors();
  }

  Future<void> refresh() async {
    await extractAndApply();
  }

  void setManualColors(WallpaperColors colors) {
    _currentColors = colors;
    _saveColors(colors);
    notifyListeners();
  }

  void toggle() {
    _isEnabled = !_isEnabled;
    notifyListeners();
  }

  Future<void> requestPermissionManually() async {
    await requestPermission();
  }
}