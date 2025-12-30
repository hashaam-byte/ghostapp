import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quest_model.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  List<Quest> _quests = [];
  bool _isLoading = true;
  String _filter = 'active';

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get(
        ApiConfig.quests,
        queryParameters: {'status': _filter},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final questsJson = data['quests'] as List;

        setState(() {
          _quests = questsJson.map((json) => Quest.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createDailyQuests() async {
    try {
      final response = await ApiClient.post(
        ApiConfig.quests,
        data: {'createDaily': true},
      );

      if (response.statusCode == 200) {
        await _loadQuests();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ Daily quests created!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuests = _quests.where((q) => q.isDaily).toList();
    final otherQuests = _quests.where((q) => !q.isDaily).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Quests'),
        actions: [
          if (_filter == 'active')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _createDailyQuests,
              tooltip: 'Generate Daily Quests',
            ),
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Filter tabs
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _FilterTab(
                    label: 'Active',
                    isSelected: _filter == 'active',
                    onTap: () {
                      setState(() => _filter = 'active');
                      _loadQuests();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Completed',
                    isSelected: _filter == 'completed',
                    onTap: () {
                      setState(() => _filter = 'completed');
                      _loadQuests();
                    },
                  ),
                ],
              ),
            ),

            // Quests list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _quests.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadQuests,
                          color: AppColors.auraStart,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              // Daily quests
                              if (dailyQuests.isNotEmpty) ...[
                                const Text(
                                  '⚡ Daily Quests',
                                  style: TextStyle(
                                    color: AppTheme.ghostWhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...dailyQuests.map((quest) {
                                  return _QuestCard(
                                    quest: quest,
                                    onComplete: () => _completeQuest(quest),
                                  )
                                      .animate()
                                      .fadeIn(duration: 400.ms)
                                      .slideX(begin: -0.2, end: 0);
                                }),
                                const SizedBox(height: 24),
                              ],

                              // Other quests
                              if (otherQuests.isNotEmpty) ...[
                                const Text(
                                  '🎯 Challenges',
                                  style: TextStyle(
                                    color: AppTheme.ghostWhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...otherQuests.map((quest) {
                                  return _QuestCard(
                                    quest: quest,
                                    onComplete: () => _completeQuest(quest),
                                  )
                                      .animate()
                                      .fadeIn(duration: 400.ms)
                                      .slideX(begin: -0.2, end: 0);
                                }),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _filter == 'completed'
                ? 'No completed quests yet'
                : 'No active quests',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          if (_filter == 'active')
            TextButton.icon(
              onPressed: _createDailyQuests,
              icon: const Icon(Icons.add_circle),
              label: const Text('Generate Daily Quests'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.auraStart,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _completeQuest(Quest quest) async {
    try {
      final response = await ApiClient.post(
        ApiConfig.quests,
        data: {
          'questId': quest.id,
          'progress': quest.target,
          'action': 'complete',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final rewards = data['rewards'];

        if (mounted && rewards != null) {
          _showRewardsDialog(rewards);
        }

        await _loadQuests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRewardsDialog(Map<String, dynamic> rewards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          '🎉 Quest Complete!',
          style: TextStyle(color: AppTheme.ghostWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rewards['xp'] != null)
              Text(
                '⚡ +${rewards['xp']} XP',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (rewards['coins'] != null) ...[
              const SizedBox(height: 8),
              Text(
                '💎 +${rewards['coins']} Coins',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 20,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.ghostAuraGradient : null,
            color: isSelected ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.ghostWhite,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onComplete;

  const _QuestCard({
    required this.quest,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _getDifficultyColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quest.title,
                  style: const TextStyle(
                    color: AppTheme.ghostWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  quest.difficulty.toUpperCase(),
                  style: TextStyle(
                    color: _getDifficultyColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quest.description,
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${quest.progress} / ${quest.target} ${quest.unit}',
                    style: const TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${quest.progressPercentage.toInt()}%',
                    style: TextStyle(
                      color: AppColors.auraStart,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: quest.progressPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(AppColors.auraStart),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rewards & Complete button
          Row(
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.xpReward} XP',
                    style: const TextStyle(
                      color: AppTheme.ghostWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('💎', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.coinReward}',
                    style: const TextStyle(
                      color: AppTheme.ghostWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (quest.progress >= quest.target)
                ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Claim'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (quest.difficulty) {
      case 'hard':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}