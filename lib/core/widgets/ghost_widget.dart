// lib/core/widgets/ghost_widget.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class GhostWidget extends StatefulWidget {
  final double size;
  final bool showAura;
  final bool isAnimated;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? mood;

  const GhostWidget({
    super.key,
    this.size = 120,
    this.showAura = true,
    this.isAnimated = true,
    this.onTap,
    this.onLongPress,
    this.mood,
  });

  @override
  State<GhostWidget> createState() => _GhostWidgetState();
}

class _GhostWidgetState extends State<GhostWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use AppColors which are updated by WallpaperService
    final ghostTint = AppColors.ghostTint;
    final auraStart = AppColors.auraStart;
    final auraEnd = AppColors.auraEnd;
    final particleColor = AppColors.particleColor;
    
    // Responsive size
    final responsiveSize = Responsive.responsive(
      context,
      mobile: widget.size,
      tablet: widget.size * 1.4,
      desktop: widget.size * 1.8,
    );

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pulseController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pulseController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pulseController.reverse();
      },
      onLongPress: widget.onLongPress,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aura ring (wallpaper-adaptive) 🌀
          if (widget.showAura)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isPressed 
                  ? responsiveSize * 1.4 
                  : responsiveSize * 1.5,
              height: _isPressed 
                  ? responsiveSize * 1.4 
                  : responsiveSize * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    auraStart.withOpacity(0.6),
                    auraEnd.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: auraStart.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            )
                .animate(
                  onPlay: (controller) => 
                      widget.isAnimated ? controller.repeat(reverse: true) : null,
                )
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                )
                .then()
                .shimmer(
                  duration: 2.seconds,
                  color: Colors.white24,
                ),

          // Ghost body (wallpaper-tinted) 👻
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isPressed 
                ? responsiveSize * 0.9 
                : responsiveSize,
            height: _isPressed 
                ? responsiveSize * 0.9 
                : responsiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ghostTint,
                  ghostTint.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: auraStart.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getGhostEmoji(),
                style: TextStyle(fontSize: responsiveSize * 0.5),
              ),
            ),
          )
              .animate(
                onPlay: (controller) => 
                    widget.isAnimated ? controller.repeat(reverse: true) : null,
              )
              .moveY(
                begin: -5,
                end: 5,
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),

          // Particle effects (wallpaper-colored) ✨
          if (widget.showAura)
            ...List.generate(6, (index) {
              return Positioned(
                left: responsiveSize * 0.3 + (index * 15),
                top: responsiveSize * 0.2 + (index % 3 * 20),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: particleColor.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: particleColor.withOpacity(0.8),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                )
                    .animate(
                      onPlay: (controller) => 
                          widget.isAnimated ? controller.repeat() : null,
                    )
                    .moveY(
                      begin: 0,
                      end: -30,
                      duration: Duration(seconds: 2 + index),
                      curve: Curves.easeOut,
                    )
                    .fadeOut(
                      duration: Duration(seconds: 2 + index),
                    ),
              );
            }),
        ],
      ),
    );
  }

  String _getGhostEmoji() {
    switch (widget.mood) {
      case 'happy':
        return '👻';
      case 'excited':
        return '✨👻';
      case 'sleeping':
        return '😴';
      case 'thinking':
        return '🤔';
      case 'focused':
        return '🎯';
      case 'celebration':
        return '🎉';
      default:
        return '👻';
    }
  }
}