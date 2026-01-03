import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import '../services/wallpaper_sync_service.dart';
import '../../main.dart';

class GradientBackground extends ConsumerWidget {
  final Widget child;
  final bool useWallpaper;
  final double blur;
  final double darken;

  const GradientBackground({
    super.key,
    required this.child,
    this.useWallpaper = true,
    this.blur = 20,
    this.darken = 0.35,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 CRITICAL: Watch wallpaper service for real-time updates
    final wallpaperService = ref.watch(wallpaperServiceProvider);
    final wallpaperBytes = wallpaperService.wallpaperBytes;
    final colors = wallpaperService.currentColors;
    final isEnabled = wallpaperService.isEnabled;

    return Stack(
      children: [
        // Background Layer
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: useWallpaper && isEnabled && wallpaperBytes != null
                ? _buildWallpaperBackground(wallpaperBytes, colors)
                : _buildGradientBackground(colors),
          ),
        ),

        // Content
        child,
      ],
    );
  }

  Widget _buildWallpaperBackground(Uint8List bytes, WallpaperColors? colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Wallpaper image (blurred) 🖼️
        Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
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

        // Gradient overlay for depth (wallpaper-derived) 🎨
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