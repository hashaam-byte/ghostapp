// lib/features/gx_core/gx_core_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/gx_aura_widget.dart';
import '../../core/widgets/gesture_detector_wrapper.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../models/user_model.dart';
import '../quests/quests_screen.dart';
import '../chat/gx_talk_screen.dart';
import '../ghost_space/quick_actions_sheet.dart';

class GXCoreScreen extends ConsumerStatefulWidget {
  const GXCoreScreen({super.key});

  @override
  ConsumerState<GXCoreScreen> createState() => _GXCoreScreenState();
}

class _GXCoreScreenState extends ConsumerState<GXCoreScreen> {
  User? _user;
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String _auraMessage = 'Tap me to talk';
  DateTime _lastInteraction = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
    _startAuraUpdates();
  }

  void _startAuraUpdates() {
    // Update aura message based on time
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final messages = [
          'What\'s on your mind?',
          'Ready to focus?',
          'Let\'s grow together',
          'I\'m here when you need me',
        ];
        setState(() {
          _auraMessage = messages[DateTime.now().second % messages.length];
        });
        _startAuraUpdates();
      }
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userData = await StorageService.getUser();
      if (userData != null) {
        setState(() {
          _user = User.fromJson(userData);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await ApiClient.get(ApiConfig.dashboardStats);
      
      if (response.statusCode == 200) {
        setState(() {
          _stats = response.data['stats'];
        });
      }
    } catch (e) {
      debugPrint('Failed to load stats: $e');
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadUserData(),
      _loadStats(),
    ]);
  }

  void _handleAuraTap() {
    GhostHaptics.medium();
    
    // Show quick dialog
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.auraStart.withOpacity(0.95),
                AppColors.auraEnd.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.auraStart.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚡',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hey there!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'What do you want to do?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.chat_bubble,
                      label: 'Talk',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GXTalkScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.psychology,
                      label: 'Focus',
                      onTap: () {
                        Navigator.pop(context);
                        _showPulseActions();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(
        duration: 300.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _handleAuraHold() {
    GhostHaptics.heavy();
    _showPulseActions();
  }

  void _showPulseActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const GXPulseActions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.auraStart),
          ),
        ),
      );
    }

    final gxProfile = _user?.ghostProfile;
    final level = gxProfile?.level ?? 1;
    final totalXP = gxProfile?.totalXP ?? 0;
    final xpToNext = gxProfile?.xpToNextLevel ?? 100;
    final coins = gxProfile?.coins ?? 0;
    
    final currentLevelXP = (level - 1) * 100;
    final xpProgress = totalXP - currentLevelXP;
    final xpNeeded = xpToNext;
    final progressPercent = (xpProgress / xpNeeded).clamp(0.0, 1.0);

    final todayXP = _stats?['today']?['xp'] ?? 0;
    final streakDays = _stats?['streaks']?['productivity'] ?? 0;
    final pendingTasks = _stats?['tasks']?['pending'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.auraStart,
            child: GhostGestureZone(
              onGhostTap: _handleAuraTap,
              onGhostHold: _handleAuraHold,
              onNavigateChat: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GXTalkScreen()),
                );
                GhostHaptics.light();
              },
              onShowActions: () {
                _showPulseActions();
                GhostHaptics.light();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Top bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: Responsive.padding(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Level badge
                          _TopBadge(
                            icon: Icons.auto_awesome,
                            label: 'L$level',
                            gradient: true,
                          ).animate().fadeIn(duration: 600.ms).scale(),

                          // Coins
                          _TopBadge(
                            icon: null,
                            emoji: '💎',
                            label: coins.toString(),
                          ).animate().fadeIn(duration: 600.ms, delay: 100.ms).scale(),
                        ],
                      ),
                    ),
                  ),

                  // Main content
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        const Spacer(),

                        // GX Aura
                        Column(
                          children: [
                            GXAuraWidget(
                              size: Responsive.ghostSize(context),
                              showParticles: true,
                              isAnimated: true,
                              mood: gxProfile?.currentMood ?? 'happy',
                              level: level,
                              onTap: _handleAuraTap,
                              onLongPress: _handleAuraHold,
                            ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),

                            SizedBox(height: context.responsiveValue(mobile: 24, tablet: 32)),

                            // Aura message
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.auraStart.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _auraMessage,
                                style: const TextStyle(
                                  color: AppTheme.ghostWhite,
                                  fontSize: 14,
                                ),
                              ),
                            )
                                .animate(
                                  key: ValueKey(_auraMessage),
                                )
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 24),

                            // XP Progress
                            Column(
                              children: [
                                Text(
                                  '$xpProgress / $xpNeeded XP',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ).animate().fadeIn(delay: 400.ms),
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
                                    widthFactor: progressPercent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppColors.ghostAuraGradient,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.auraStart.withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 500.ms).slideX(),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Gesture hints
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _GestureHint(icon: Icons.touch_app, label: 'Tap'),
                                const SizedBox(width: 16),
                                _GestureHint(icon: Icons.pan_tool, label: 'Hold'),
                                const SizedBox(width: 16),
                                _GestureHint(icon: Icons.swipe, label: 'Swipe'),
                              ],
                            )
                                .animate(onPlay: (controller) => controller.repeat())
                                .fadeIn(duration: 2.seconds)
                                .fadeOut(duration: 2.seconds, delay: 3.seconds),
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
                                  value: streakDays.toString(),
                                  color: AppColors.error,
                                ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.trending_up,
                                  label: 'Today',
                                  value: '$todayXP XP',
                                  color: AppColors.success,
                                ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 0.2),
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
                                    icon: Icons.task_alt,
                                    label: 'Tasks',
                                    value: pendingTasks.toString(),
                                    color: AppColors.auraStart,
                                  ),
                                ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.2),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widgets
class _TopBadge extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String label;
  final bool gradient;

  const _TopBadge({
    this.icon,
    this.emoji,
    required this.label,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveValue(mobile: 16, tablet: 20),
        vertical: context.responsiveValue(mobile: 8, tablet: 12),
      ),
      decoration: BoxDecoration(
        gradient: gradient ? AppColors.ghostAuraGradient : null,
        color: gradient ? null : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: gradient 
              ? Colors.transparent 
              : Colors.white.withOpacity(0.2),
        ),
        boxShadow: gradient
            ? [
                BoxShadow(
                  color: AppColors.auraStart.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: context.responsiveValue(mobile: 16, tablet: 20),
              color: Colors.white,
            ),
          if (emoji != null)
            Text(
              emoji!,
              style: TextStyle(
                fontSize: context.responsiveValue(mobile: 16, tablet: 20),
              ),
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.responsiveValue(mobile: 14, tablet: 16),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GestureHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GestureHint({required this.icon, required this.label});

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
        context.responsiveValue(mobile: 16, tablet: 20),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}