// lib/core/services/background_image_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundImageService extends ChangeNotifier {
  static const String _bgImageKey = 'background_image_path';
  
  File? _backgroundImage;
  bool _isLoading = false;
  
  File? get backgroundImage => _backgroundImage;
  bool get isLoading => _isLoading;
  bool get hasBackground => _backgroundImage != null;

  /// Initialize - load saved background image
  Future<void> initialize() async {
    debugPrint('🖼️ Initializing Background Image Service...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString(_bgImageKey);
      
      if (path != null && File(path).existsSync()) {
        _backgroundImage = File(path);
        debugPrint('✅ Background image loaded: $path');
      } else {
        debugPrint('ℹ️ No background image set');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Failed to load background image: $e');
    }
  }

  /// Pick image from gallery
  Future<bool> pickFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Pick image from camera
  Future<bool> pickFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  /// Internal image picker
  Future<bool> _pickImage(ImageSource source) async {
    _isLoading = true;
    notifyListeners();

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85, // Compress to reduce file size
      );

      if (pickedFile == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Copy to app storage
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'background_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = File('${appDir.path}/$fileName');
      
      await File(pickedFile.path).copy(savedFile.path);

      // Delete old background if exists
      if (_backgroundImage != null && _backgroundImage!.existsSync()) {
        try {
          await _backgroundImage!.delete();
        } catch (e) {
          debugPrint('⚠️ Failed to delete old background: $e');
        }
      }

      // Save new background
      _backgroundImage = savedFile;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_bgImageKey, savedFile.path);

      debugPrint('✅ Background image saved: ${savedFile.path}');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to pick image: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove background image
  Future<void> removeBackground() async {
    if (_backgroundImage != null && _backgroundImage!.existsSync()) {
      try {
        await _backgroundImage!.delete();
      } catch (e) {
        debugPrint('⚠️ Failed to delete background: $e');
      }
    }

    _backgroundImage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bgImageKey);

    debugPrint('🗑️ Background image removed');
    notifyListeners();
  }
}