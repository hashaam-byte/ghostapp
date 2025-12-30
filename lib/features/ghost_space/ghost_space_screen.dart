import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/widgets/gesture_detector_wrapper.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../models/user_model.dart';
import '../quests/quests_screen.dart';
import '../chat/chat_screen.dart';
import 'quick_actions_sheet.dart';

class GhostSpaceScreen extends ConsumerStatefulWidget {
  const GhostSpaceScreen({super.key});

  @override
  ConsumerState<GhostSpaceScreen> createState() => _GhostSpaceScreenState();
}

class _GhostSpaceScreenState extends ConsumerState<GhostSpaceScreen> {
  User? _user;
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
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
    if (_isLoadingStats) return;
    
    setState(() => _isLoadingStats = true);

    try {
      final response = await ApiClient.get(ApiConfig.dashboardStats);
      
      if (response.statusCode == 200) {
        setState(() {
          _stats = response.data['stats'];
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load stats: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadUserData(),
      _loadStats(),
    ]);
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

    final ghostProfile = _user?.ghostProfile;
    final level = ghostProfile?.level ?? 1;
    final totalXP = ghostProfile?.totalXP ?? 0;
    final xpToNext = ghostProfile?.xpToNextLevel ?? 100;
    final coins = ghostProfile?.coins ?? 0;
    
    // Calculate XP progress
    final currentLevelXP = (level - 1) * 100;
    final xpProgress = totalXP - currentLevelXP;
    final xpNeeded = xpToNext;
    final progressPercent = (xpProgress / xpNeeded).clamp(0.0, 1.0);

    // Stats from server
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
              onGhostTap: () {
                _showGhostDialog(context);
                GhostHaptics.medium();
              },
              onGhostHold: () {
                _showQuickActionsSheet(context);
                GhostHaptics.heavy();
              },
              onNavigateChat: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
                GhostHaptics.light();
              },
              onShowActions: () {
                _showQuickActionsSheet(context);
                GhostHaptics.light();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Top bar with level and coins
                  SliverToBoxAdapter(
                    child: Padding(
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
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.auraStart.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: context.responsiveValue(
                                    mobile: 16,
                                    tablet: 20,
                                  ),
                                  color: Colors.white,
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
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 600.ms).scale(),

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
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
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
                                    color: AppTheme.ghostWhite,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 100.ms).scale(),
                        ],
                      ),
                    ),
                  ),

                  // Ghost center piece
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        const Spacer(),

                        // Ghost with tap instruction
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
                                _showQuickActionsSheet(context);
                              },
                            ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),

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

                            const SizedBox(height: 16),

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
                                  isLoading: _isLoadingStats,
                                ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.trending_up,
                                  label: 'Today',
                                  value: '$todayXP XP',
                                  color: AppColors.success,
                                  isLoading: _isLoadingStats,
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
                                    isLoading: _isLoadingStats,
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

  void _showGhostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.auraStart,
                AppColors.auraEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.auraStart.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.auraStart,
                      ),
                      child: const Text('Let\'s chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QuickActionsSheet(),
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
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLoading = false,
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
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          else
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