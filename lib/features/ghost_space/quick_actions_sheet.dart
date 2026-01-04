// lib/features/gx_core/gx_pulse_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../study/gx_focus_mode_screen.dart';

class GXPulseActions extends StatelessWidget {
  const GXPulseActions({super.key});

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
        top: false,
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

            // Title with glow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.ghostAuraGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.auraStart.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'GX Pulse',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppTheme.ghostWhite.withOpacity(0.6),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Actions grid
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Row 1: Focus & Study
                  Row(
                    children: [
                      Expanded(
                        child: _PulseActionCard(
                          icon: Icons.psychology,
                          label: 'Focus',
                          subtitle: '25 min',
                          color: AppColors.auraStart,
                          gradient: true,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GXFocusModeScreen(
                                  durationMinutes: 25,
                                  mode: 'focus',
                                ),
                              ),
                            );
                          },
                        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PulseActionCard(
                          icon: Icons.school,
                          label: 'Study',
                          subtitle: '50 min',
                          color: AppColors.success,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GXFocusModeScreen(
                                  durationMinutes: 50,
                                  mode: 'study',
                                ),
                              ),
                            );
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.2),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  // Row 2: Lock & Sleep
                  Row(
                    children: [
                      Expanded(
                        child: _PulseActionCard(
                          icon: Icons.block,
                          label: 'Lock Apps',
                          subtitle: '1 hour',
                          color: AppColors.error,
                          onTap: () {
                            Navigator.pop(context);
                            _showComingSoon(context, 'App Locker');
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PulseActionCard(
                          icon: Icons.nightlight,
                          label: 'Sleep',
                          subtitle: 'Until 7 AM',
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.pop(context);
                            _activateSleepMode(context);
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Long action: Phone boost
                  _PulseLongAction(
                    icon: Icons.cleaning_services,
                    label: 'Boost Phone',
                    subtitle: 'Clear cache & optimize',
                    color: AppColors.auraEnd,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Phone Optimizer');
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  // Long action: Scan
                  _PulseLongAction(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan',
                    subtitle: 'QR, Crypto, DM Safety',
                    color: AppColors.auraStart,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Scanner');
                    },
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.2),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon! ⚡'),
        backgroundColor: AppColors.auraStart,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _activateSleepMode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💤 Sleep mode activated until 7 AM'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PulseActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool gradient;
  final VoidCallback onTap;

  const _PulseActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.gradient = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient ? AppColors.ghostAuraGradient : null,
          color: gradient ? null : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gradient ? Colors.transparent : color.withOpacity(0.3),
          ),
          boxShadow: gradient
              ? [
                  BoxShadow(
                    color: AppColors.auraStart.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gradient ? Colors.white.withOpacity(0.2) : Colors.transparent,
                gradient: gradient ? null : LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.ghostWhite.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseLongAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PulseLongAction({
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.ghostWhite.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.ghostWhite.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}