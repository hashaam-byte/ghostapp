import 'package:flutter/material.dart';
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
    return Stack(
      children: [
        // Gradient overlay
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