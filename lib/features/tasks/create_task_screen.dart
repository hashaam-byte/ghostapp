import 'package:flutter/material.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'personal';
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'personal', 'label': 'Personal', 'icon': '👤'},
    {'value': 'work', 'label': 'Work', 'icon': '💼'},
    {'value': 'study', 'label': 'Study', 'icon': '📚'},
    {'value': 'health', 'label': 'Health', 'icon': '💪'},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Low', 'color': AppColors.success},
    {'value': 'medium', 'label': 'Medium', 'color': AppColors.warning},
    {'value': 'high', 'label': 'High', 'color': AppColors.error},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        ApiConfig.createTask,
        data: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _category,
          'priority': _priority,
          if (_dueDate != null) 'dueDate': _dueDate!.toIso8601String(),
        },
      );

      if (response.statusCode == 201 && mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Task created!'),
            backgroundColor: AppColors.success,
          ),
        );
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.auraStart,
              surface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Task'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextField(
                    label: 'Task Title',
                    hint: 'What do you need to do?',
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Description
                  CustomTextField(
                    label: 'Description (Optional)',
                    hint: 'Add more details...',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _category == cat['value'];
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.ghostAuraGradient
                                : null,
                            color: isSelected
                                ? null
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat['icon'],
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat['label'],
                                style: const TextStyle(
                                  color: AppTheme.ghostWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Priority
                  const Text(
                    'Priority',
                    style: TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _priorities.map((priority) {
                      final isSelected = _priority == priority['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _priority = priority['value']),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority['color'].withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? priority['color']
                                    : Colors.white.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              priority['label'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? priority['color']
                                    : AppTheme.ghostWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Due Date
                  const Text(
                    'Due Date (Optional)',
                    style: TextStyle(
                      color: AppTheme.ghostWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _selectDueDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.auraStart,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _dueDate == null
                                ? 'Select due date'
                                : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                            style: const TextStyle(
                              color: AppTheme.ghostWhite,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              color: AppTheme.ghostWhite,
                              onPressed: () => setState(() => _dueDate = null),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Create Button
                  CustomButton(
                    text: 'Create Task',
                    onPressed: _createTask,
                    isLoading: _isLoading,
                    width: double.infinity,
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