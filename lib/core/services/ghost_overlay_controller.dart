// lib/core/services/ghost_overlay_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class GhostOverlayController {
  static const MethodChannel _channel = MethodChannel('ghostx/overlay');
  
  static bool _isRunning = false;
  static bool get isRunning => _isRunning;

  /// Check if overlay permission is granted
  static Future<bool> hasPermission() async {
    if (await Permission.systemAlertWindow.isGranted) {
      return true;
    }
    return false;
  }

  /// Request overlay permission
  static Future<bool> requestPermission() async {
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }

  /// Start Ghost Overlay (floating window)
  static Future<bool> startOverlay() async {
    try {
      // Check permission first
      if (!await hasPermission()) {
        debugPrint('❌ Overlay permission not granted');
        return false;
      }

      // Call native method to start service
      final result = await _channel.invokeMethod('startOverlay');
      
      if (result == true) {
        _isRunning = true;
        debugPrint('✅ Ghost Overlay started');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Failed to start overlay: $e');
      return false;
    }
  }

  /// Stop Ghost Overlay
  static Future<bool> stopOverlay() async {
    try {
      final result = await _channel.invokeMethod('stopOverlay');
      
      if (result == true) {
        _isRunning = false;
        debugPrint('🛑 Ghost Overlay stopped');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Failed to stop overlay: $e');
      return false;
    }
  }

  /// Update overlay position
  static Future<void> updatePosition(double x, double y) async {
    try {
      await _channel.invokeMethod('updatePosition', {
        'x': x,
        'y': y,
      });
    } catch (e) {
      debugPrint('❌ Failed to update position: $e');
    }
  }

  /// Update overlay settings
  static Future<void> updateSettings({
    String? size,
    String? snapEdge,
    double? opacity,
  }) async {
    try {
      await _channel.invokeMethod('updateSettings', {
        'size': size,
        'snapEdge': snapEdge,
        'opacity': opacity,
      });
    } catch (e) {
      debugPrint('❌ Failed to update settings: $e');
    }
  }
}