// lib/core/widgets/gradient_background.dart - UPDATED WITH IMAGE SUPPORT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'dart:io';
import '../theme/app_theme.dart';
import '../services/wallpaper_sync_service.dart';
import '../../main.dart';

class GradientBackground extends ConsumerWidget {
  final Widget child;
  final bool useCustomBackground; // Use user's selected image
  final bool useWallpaper; // Use device wallpaper (old behavior)
  final double blur;
  final double darken;

  const GradientBackground({
    super.key,
    required this.child,
    this.useCustomBackground = true, // NEW: prioritize user image
    this.useWallpaper = false, // Keep wallpaper feature as backup
    this.blur = 20,
    this.darken = 0.35,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both services
    final wallpaperService = ref.watch(wallpaperServiceProvider);
    final bgImageService = ref.watch(backgroundImageServiceProvider);
    
    final colors = wallpaperService.currentColors;

    return Stack(
      children: [
        // Background Layer (Priority: Custom Image > Wallpaper > Gradient)
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: _buildBackground(
              bgImageService.backgroundImage,
              wallpaperService.wallpaperBytes,
              colors,
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }

  Widget _buildBackground(
    File? customImage,
    dynamic wallpaperBytes,
    WallpaperColors? colors,
  ) {
    // 🎯 Priority 1: User's custom background image
    if (useCustomBackground && customImage != null && customImage.existsSync()) {
      return _buildImageBackground(customImage, colors);
    }

    // 🎯 Priority 2: Device wallpaper (old behavior)
    if (useWallpaper && wallpaperBytes != null) {
      return _buildWallpaperBackground(wallpaperBytes, colors);
    }

    // 🎯 Priority 3: Gradient fallback
    return _buildGradientBackground(colors);
  }

  // Custom image background (NEW!)
  Widget _buildImageBackground(File imageFile, WallpaperColors? colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // User's image
        Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Failed to load custom image: $error');
            return _buildGradientBackground(colors);
          },
        ),

        // Blur effect 🌫️
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            color: Colors.black.withOpacity(darken),
          ),
        ),

        // Gradient overlay for depth 🎨
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (colors?.auraStart ?? AppColors.auraStart).withOpacity(0.15),
                Colors.black.withOpacity(0.2),
                (colors?.auraEnd ?? AppColors.auraEnd).withOpacity(0.15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Wallpaper background (old behavior)
  Widget _buildWallpaperBackground(dynamic bytes, WallpaperColors? colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildGradientBackground(colors);
          },
        ),

        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            color: Colors.black.withOpacity(darken),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (colors?.auraStart ?? AppColors.auraStart).withOpacity(0.2),
                Colors.black.withOpacity(0.3),
                (colors?.auraEnd ?? AppColors.auraEnd).withOpacity(0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Gradient fallback
  Widget _buildGradientBackground(WallpaperColors? colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (colors?.auraStart ?? AppColors.auraStart).withOpacity(0.3),
            Colors.black,
            (colors?.auraEnd ?? AppColors.auraEnd).withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}