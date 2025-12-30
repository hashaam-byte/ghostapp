import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class GhostWidget extends StatelessWidget {
  final double size;
  final bool showAura;
  final bool isAnimated; // renamed from `animate`
  final VoidCallback? onTap;
  final String? mood;

  const GhostWidget({
    super.key,
    this.size = 120,
    this.showAura = true,
    this.isAnimated = true, // renamed param
    this.onTap,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura ring
          if (showAura)
            Container(
              width: size * 1.5,
              height: size * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.ghostAuraGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auraStart.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            )
                .animate(
                  onPlay: (controller) => isAnimated ? controller.repeat() : null,
                )
                .shimmer(duration: 2.seconds, color: Colors.white24)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                ),

          // Ghost body
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.ghostTint,
                  AppColors.ghostTint.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Text(
                _getGhostEmoji(),
                style: TextStyle(fontSize: size * 0.5),
              ),
            ),
          )
              .animate(
                onPlay: (controller) => isAnimated ? controller.repeat() : null,
              )
              .moveY(
                begin: -5,
                end: 5,
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  String _getGhostEmoji() {
    switch (mood) {
      case 'happy':
        return '👻';
      case 'excited':
        return '✨👻';
      case 'sleeping':
        return '😴';
      case 'thinking':
        return '🤔';
      default:
        return '👻';
    }
  }
}