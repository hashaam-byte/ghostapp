// lib/features/pulse/gx_pulse_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gesture_detector_wrapper.dart';

/// GX Pulse - System-level floating overlay
/// This is the "always accessible" bubble that appears system-wide
class GXPulseWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GXPulseWidget({
    super.key,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<GXPulseWidget> createState() => _GXPulseWidgetState();
}

class _GXPulseWidgetState extends State<GXPulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Offset _position = const Offset(0.9, 0.5); // Right center
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: _position.dx * size.width - 30,
      top: _position.dy * size.height - 30,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              (_position.dx * size.width + details.delta.dx) / size.width,
              (_position.dy * size.height + details.delta.dy) / size.height,
            );
          });
        },
        onPanEnd: (details) {
          // Snap to nearest edge
          setState(() {
            if (_position.dx < 0.5) {
              _position = Offset(0.1, _position.dy);
            } else {
              _position = Offset(0.9, _position.dy);
            }
          });
        },
        onTap: () {
          GhostHaptics.medium();
          setState(() => _isExpanded = !_isExpanded);
          widget.onTap?.call();
        },
        onLongPress: () {
          GhostHaptics.heavy();
          widget.onLongPress?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isExpanded ? 200 : 60,
          height: 60,
          child: Stack(
            children: [
              // Pulsing aura
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 60 + (_pulseController.value * 20),
                    height: 60 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.auraStart.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Main bubble
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.ghostAuraGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.auraStart.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '⚡',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),

              // Expanded actions
              if (_isExpanded)
                Positioned(
                  left: 70,
                  child: Container(
                    width: 130,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.auraStart.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QuickAction(
                          icon: Icons.psychology,
                          onTap: () {
                            // Start focus mode
                          },
                        ),
                        _QuickAction(
                          icon: Icons.block,
                          onTap: () {
                            // Lock apps
                          },
                        ),
                        _QuickAction(
                          icon: Icons.chat_bubble,
                          onTap: () {
                            // Open chat
                          },
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .slideX(begin: -0.5, end: 0),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GhostHaptics.light();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: AppTheme.ghostWhite,
          size: 18,
        ),
      ),
    );
  }
}

/// GX Pulse Commands Sheet
/// Shows when user long-presses the pulse
class GXPulseCommandsSheet extends StatelessWidget {
  const GXPulseCommandsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A1A),
            Colors.black.withOpacity(0.95),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '⚡ GX Commands',
                style: TextStyle(
                  color: AppTheme.ghostWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Voice trigger
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.ghostAuraGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Command',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Say "Hey GX" to activate',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick commands grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _CommandCard(
                    icon: Icons.psychology,
                    label: 'Focus Mode',
                    subtitle: '25 min',
                    color: AppColors.auraStart,
                    onTap: () {},
                  ),
                  _CommandCard(
                    icon: Icons.school,
                    label: 'Study Mode',
                    subtitle: '50 min',
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  _CommandCard(
                    icon: Icons.block,
                    label: 'Lock Apps',
                    subtitle: '1 hour',
                    color: AppColors.error,
                    onTap: () {},
                  ),
                  _CommandCard(
                    icon: Icons.nightlight,
                    label: 'Sleep Mode',
                    subtitle: 'Until 7 AM',
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CommandCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.ghostWhite.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}