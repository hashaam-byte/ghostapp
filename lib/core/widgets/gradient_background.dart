// lib/core/widgets/gradient_background.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Use AppColors which are updated by WallpaperService
    return Stack(
      children: [
        // Background gradient using current theme colors
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.auraStart.withOpacity(0.3),
                  Colors.black,
                  AppColors.auraEnd.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}