import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import 'create_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, completed

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get(ApiConfig.tasks);

      if (response.statusCode == 200) {
        final data = response.data;
        final tasksJson = data['tasks'] as List;

        setState(() {
          _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
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

  Future<void> _completeTask(Task task) async {
    try {
      final response = await ApiClient.post(
        ApiConfig.completeTask(task.id),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final xpEarned = data['xpEarned'] ?? 0;

        // Show XP notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 +$xpEarned XP earned!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Reload tasks
        await _loadTasks();
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

  Future<void> _deleteTask(Task task) async {
    try {
      final response = await ApiClient.delete(
        ApiConfig.deleteTask(task.id),
      );

      if (response.statusCode == 200) {
        await _loadTasks();
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

  List<Task> get _filteredTasks {
    switch (_filter) {
      case 'pending':
        return _tasks.where((t) => t.isPending).toList();
      case 'completed':
        return _tasks.where((t) => t.isCompleted).toList();
      default:
        return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_tasks.where((t) => t.isPending).length} pending',
                          style: TextStyle(
                            color: AppTheme.ghostWhite.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: AppColors.auraStart,
                      iconSize: 32,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateTaskScreen(),
                          ),
                        );
                        _loadTasks();
                      },
                    ),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Pending',
                      isSelected: _filter == 'pending',
                      onTap: () => setState(() => _filter = 'pending'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Completed',
                      isSelected: _filter == 'completed',
                      onTap: () => setState(() => _filter = 'completed'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tasks list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTasks.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadTasks,
                            color: AppColors.auraStart,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = _filteredTasks[index];
                                return _TaskCard(
                                  task: task,
                                  onComplete: () => _completeTask(task),
                                  onDelete: () => _deleteTask(task),
                                )
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: (50 * index).ms,
                                    )
                                    .slideX(begin: -0.2, end: 0);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📋',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            _filter == 'completed'
                ? 'No completed tasks yet'
                : 'No tasks yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first task',
            style: TextStyle(
              color: AppTheme.ghostWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.ghostAuraGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.ghostWhite,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onDelete,
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
          color: _getPriorityColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Complete checkbox
          GestureDetector(
            onTap: task.isCompleted ? null : onComplete,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: task.isCompleted
                    ? AppColors.ghostAuraGradient
                    : null,
                border: task.isCompleted
                    ? null
                    : Border.all(
                        color: AppTheme.ghostWhite.withOpacity(0.3),
                        width: 2,
                      ),
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: AppTheme.ghostWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: TextStyle(
                      color: AppTheme.ghostWhite.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTag(
                      task.category,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      '${task.xpReward} XP',
                      AppColors.success,
                    ),
                    if (task.isOverdue) ...[
                      const SizedBox(width: 8),
                      _buildTag('Overdue', AppColors.error),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text(
                    'Delete Task?',
                    style: TextStyle(color: AppTheme.ghostWhite),
                  ),
                  content: const Text(
                    'This action cannot be undone.',
                    style: TextStyle(color: AppTheme.ghostWhite),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }
}