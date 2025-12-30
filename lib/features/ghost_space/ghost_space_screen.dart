import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/widgets/gesture_detector_wrapper.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../models/user_model.dart';
import '../quests/quests_screen.dart';
import '../chat/chat_screen.dart';

class GhostSpaceScreen extends ConsumerStatefulWidget {
  const GhostSpaceScreen({super.key});

  @override
  ConsumerState<GhostSpaceScreen> createState() => _GhostSpaceScreenState();
}

class _GhostSpaceScreenState extends ConsumerState<GhostSpaceScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await StorageService.getUser();
    if (userData != null) {
      setState(() {
        _user = User.fromJson(userData);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ghostProfile = _user?.ghostProfile;
    final level = ghostProfile?.level ?? 1;
    final totalXP = ghostProfile?.totalXP ?? 0;
    final xpToNext = ghostProfile?.xpToNextLevel ?? 100;
    final coins = ghostProfile?.coins ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: GhostGestureZone(
            onGhostTap: () {
              _showGhostDialog(context);
              GhostHaptics.medium();
            },
            onGhostHold: () {
              _showQuickActions(context);
              GhostHaptics.heavy();
            },
            onNavigateChat: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
              GhostHaptics.light();
            },
            onShowActions: () {
              _showQuickActions(context);
              GhostHaptics.light();
            },
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: Responsive.padding(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveValue(
                            mobile: 16,
                            tablet: 20,
                          ),
                          vertical: context.responsiveValue(
                            mobile: 8,
                            tablet: 12,
                          ),
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.ghostAuraGradient,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: context.responsiveValue(
                                mobile: 16,
                                tablet: 20,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lv $level',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.responsiveValue(
                                  mobile: 14,
                                  tablet: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Coins
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.responsiveValue(
                            mobile: 16,
                            tablet: 20,
                          ),
                          vertical: context.responsiveValue(
                            mobile: 8,
                            tablet: 12,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '💎',
                              style: TextStyle(
                                fontSize: context.responsiveValue(
                                  mobile: 16,
                                  tablet: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              coins.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.responsiveValue(
                                  mobile: 14,
                                  tablet: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Ghost (center) with gesture hint
                Column(
                  children: [
                    GhostWidget(
                      size: Responsive.ghostSize(context),
                      showAura: true,
                      isAnimated: true,
                      mood: ghostProfile?.currentMood ?? 'happy',
                      onTap: () {
                        _showGhostDialog(context);
                      },
                      onLongPress: () {
                        _showQuickActions(context);
                      },
                    ),

                    SizedBox(
                      height: context.responsiveValue(
                        mobile: 24,
                        tablet: 32,
                      ),
                    ),

                    // XP Progress
                    Column(
                      children: [
                        Text(
                          '$totalXP / $xpToNext XP',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: context.responsiveValue(
                            mobile: 200,
                            tablet: 300,
                          ),
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (totalXP / xpToNext).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.ghostAuraGradient,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Gesture hints
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GestureHint(
                          icon: Icons.touch_app,
                          label: 'Tap',
                        ),
                        const SizedBox(width: 16),
                        _GestureHint(
                          icon: Icons.pan_tool,
                          label: 'Hold',
                        ),
                        const SizedBox(width: 16),
                        _GestureHint(
                          icon: Icons.swipe,
                          label: 'Swipe',
                        ),
                      ],
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 2.seconds)
                        .fadeOut(duration: 2.seconds),
                  ],
                ),

                const Spacer(),

                // Quick stats
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveValue(
                      mobile: 24,
                      tablet: 48,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department,
                          label: 'Streak',
                          value: '0',
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up,
                          label: 'Daily XP',
                          value: '0',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QuestsScreen(),
                              ),
                            );
                          },
                          child: _StatCard(
                            icon: Icons.stars,
                            label: 'Quests',
                            value: '0',
                            color: AppColors.auraStart,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: context.responsiveValue(
                    mobile: 32,
                    tablet: 48,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGhostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.ghostAuraGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '👻',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hey! What\'s up?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                child: const Text(
                  'Let\'s chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _ActionButton(
                      icon: Icons.self_improvement,
                      label: 'Focus Mode',
                      color: AppColors.auraStart,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to focus mode
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.school,
                      label: 'Study Mode',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to study mode
                      },
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.block,
                      label: 'Block Apps',
                      color: AppColors.error,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to app blocker
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GestureHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GestureHint({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.ghostWhite.withOpacity(0.4),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.ghostWhite.withOpacity(0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        context.responsiveValue(
          mobile: 16,
          tablet: 20,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
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
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
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