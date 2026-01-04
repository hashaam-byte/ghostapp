// lib/core/widgets/gx_aura_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'dart:math' as math;

class GXAuraWidget extends StatefulWidget {
  final double size;
  final bool showParticles;
  final bool isAnimated;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? mood;
  final int? level;

  const GXAuraWidget({
    super.key,
    this.size = 120,
    this.showParticles = true,
    this.isAnimated = true,
    this.onTap,
    this.onLongPress,
    this.mood,
    this.level,
  });

  @override
  State<GXAuraWidget> createState() => _GXAuraWidgetState();
}

class _GXAuraWidgetState extends State<GXAuraWidget> 
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.isAnimated) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      child: SizedBox(
        width: responsiveSize * 2,
        height: responsiveSize * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating rings
            if (widget.showParticles)
              ..._buildRotatingRings(responsiveSize),

            // Main aura glow
            _buildMainAura(responsiveSize),

            // Core entity
            _buildCore(responsiveSize),

            // Level badge
            if (widget.level != null)
              _buildLevelBadge(responsiveSize),

            // Floating particles
            if (widget.showParticles)
              ..._buildParticles(responsiveSize),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRotatingRings(double size) {
    return [
      // Outer ring
      AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: Container(
              width: size * 2,
              height: size * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.auraStart.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),

      // Middle ring
      AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: -_rotationController.value * 2 * math.pi * 0.7,
            child: Container(
              width: size * 1.5,
              height: size * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.auraEnd.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildMainAura(double size) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _isPressed 
            ? 0.95 
            : 1.0 + (_pulseController.value * 0.1);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size * 1.6,
            height: size * 1.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.auraStart.withOpacity(0.6),
                  AppColors.auraEnd.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auraStart.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCore(double size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isPressed ? size * 0.9 : size,
      height: _isPressed ? size * 0.9 : size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.ghostTint,
            AppColors.ghostTint.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.auraStart.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getAuraEmoji(),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    )
        .animate(
          onPlay: (controller) => 
              widget.isAnimated ? controller.repeat(reverse: true) : null,
        )
        .moveY(
          begin: -3,
          end: 3,
          duration: 3.seconds,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildLevelBadge(double size) {
    return Positioned(
      bottom: size * 0.1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.ghostAuraGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.auraStart.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'L${widget.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles(double size) {
    return List.generate(8, (index) {
      final angle = (index / 8) * 2 * math.pi;
      final distance = size * 0.8;

      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final progress = (_particleController.value + (index * 0.1)) % 1.0;
          final opacity = 1.0 - progress;

          return Positioned(
            left: size + (math.cos(angle) * distance * progress),
            top: size + (math.sin(angle) * distance * progress),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.particleColor.withOpacity(opacity * 0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.particleColor.withOpacity(opacity * 0.8),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  String _getAuraEmoji() {
    switch (widget.mood) {
      case 'happy':
        return '✨';
      case 'excited':
        return '⚡';
      case 'sleeping':
        return '💤';
      case 'thinking':
        return '🧠';
      case 'focused':
        return '🎯';
      case 'celebration':
        return '🎉';
      default:
        return '⚡';
    }
  }
}