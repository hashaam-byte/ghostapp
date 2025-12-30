import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../tutorial/tutorial_screen.dart';

class WakeQuestionsScreen extends StatefulWidget {
  const WakeQuestionsScreen({super.key});

  @override
  State<WakeQuestionsScreen> createState() => _WakeQuestionsScreenState();
}

class _WakeQuestionsScreenState extends State<WakeQuestionsScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // User answers
  String? _primaryGoal;
  String? _strictnessLevel;
  String? _productiveTime;
  String? _feedbackStyle;
  String? _mainStruggle;
  String? _talkFrequency;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What\'s your main goal?',
      'options': [
        {'value': 'study', 'label': '📚 Study & School', 'emoji': '📚'},
        {'value': 'business', 'label': '💼 Business & Hustle', 'emoji': '💼'},
        {'value': 'crypto', 'label': '💎 Crypto & Finance', 'emoji': '💎'},
        {'value': 'discipline', 'label': '💪 Build Discipline', 'emoji': '💪'},
        {'value': 'life', 'label': '✨ Fix My Life', 'emoji': '✨'},
      ],
    },
    {
      'question': 'How strict should I be?',
      'options': [
        {'value': 'chill', 'label': '😌 Chill & Supportive'},
        {'value': 'balanced', 'label': '⚖️ Balanced'},
        {'value': 'strict', 'label': '🔥 Strict & Tough'},
      ],
    },
    {
      'question': 'When are you most productive?',
      'options': [
        {'value': 'morning', 'label': '🌅 Morning (5AM-12PM)'},
        {'value': 'afternoon', 'label': '☀️ Afternoon (12PM-6PM)'},
        {'value': 'evening', 'label': '🌙 Evening (6PM-12AM)'},
        {'value': 'night', 'label': '🦉 Night Owl (12AM-5AM)'},
      ],
    },
    {
      'question': 'What feedback style do you prefer?',
      'options': [
        {'value': 'gentle', 'label': '🤗 Gentle & Kind'},
        {'value': 'honest', 'label': '💯 Honest & Direct'},
        {'value': 'roast', 'label': '🔥 Roast Me (Funny)'},
        {'value': 'silent', 'label': '🤫 Just Listen'},
      ],
    },
    {
      'question': 'What\'s your biggest struggle?',
      'options': [
        {'value': 'procrastination', 'label': '⏰ Procrastination'},
        {'value': 'consistency', 'label': '🎯 Consistency'},
        {'value': 'motivation', 'label': '💪 Motivation'},
        {'value': 'focus', 'label': '🧠 Focus & Attention'},
        {'value': 'overwhelm', 'label': '😰 Feeling Overwhelmed'},
      ],
    },
    {
      'question': 'How often should I check in?',
      'options': [
        {'value': 'always', 'label': '💬 Always Available'},
        {'value': 'daily', 'label': '📅 Daily Check-ins'},
        {'value': 'when_needed', 'label': '🆘 Only When I Need'},
      ],
    },
  ];

  Future<void> _submitAnswers() async {
    if (_primaryGoal == null ||
        _strictnessLevel == null ||
        _productiveTime == null ||
        _feedbackStyle == null ||
        _mainStruggle == null ||
        _talkFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post(
        ApiConfig.wakeQuestions,
        data: {
          'primaryGoal': _primaryGoal,
          'strictnessLevel': _strictnessLevel,
          'productiveTime': _productiveTime,
          'feedbackStyle': _feedbackStyle,
          'mainStruggle': _mainStruggle,
          'talkFrequency': _talkFrequency,
        },
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const TutorialScreen(),
          ),
          (route) => false,
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

  void _selectAnswer(String value) {
    setState(() {
      switch (_currentStep) {
        case 0:
          _primaryGoal = value;
          break;
        case 1:
          _strictnessLevel = value;
          break;
        case 2:
          _productiveTime = value;
          break;
        case 3:
          _feedbackStyle = value;
          break;
        case 4:
          _mainStruggle = value;
          break;
        case 5:
          _talkFrequency = value;
          break;
      }
    });

    // Auto advance to next question
    if (_currentStep < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _currentStep++);
        }
      });
    }
  }

  String? _getCurrentAnswer() {
    switch (_currentStep) {
      case 0:
        return _primaryGoal;
      case 1:
        return _strictnessLevel;
      case 2:
        return _productiveTime;
      case 3:
        return _feedbackStyle;
      case 4:
        return _mainStruggle;
      case 5:
        return _talkFrequency;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentStep];
    final currentAnswer = _getCurrentAnswer();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / _questions.length,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(AppColors.auraStart),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Ghost
                      const GhostWidget(
                        size: 80,
                        showAura: true,
                        isAnimated: true, // was `animate: true`
                      )
                          .animate(
                            key: ValueKey(_currentStep),
                          )
                          .fadeIn(duration: 400.ms)
                          .scale(delay: 100.ms),

                      const SizedBox(height: 32),

                      // Question
                      Text(
                        question['question'],
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                            ),
                        textAlign: TextAlign.center,
                      )
                          .animate(
                            key: ValueKey('q$_currentStep'),
                          )
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 40),

                      // Options
                      ...List.generate(
                        question['options'].length,
                        (index) {
                          final option = question['options'][index];
                          final isSelected = currentAnswer == option['value'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OptionCard(
                              label: option['label'],
                              isSelected: isSelected,
                              onTap: () => _selectAnswer(option['value']),
                            )
                                .animate(
                                  key: ValueKey('o$_currentStep$index'),
                                )
                                .fadeIn(
                                  duration: 400.ms,
                                  delay: (100 * index).ms,
                                )
                                .slideX(begin: -0.2, end: 0),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Navigation
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: CustomButton(
                                text: 'Back',
                                isOutlined: true,
                                onPressed: () {
                                  setState(() => _currentStep--);
                                },
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: _currentStep == _questions.length - 1
                                  ? 'Complete'
                                  : 'Next',
                              onPressed: _currentStep == _questions.length - 1
                                  ? _submitAnswers
                                  : () {
                                      if (currentAnswer != null) {
                                        setState(() => _currentStep++);
                                      }
                                    },
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.auraStart.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.auraStart : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.ghostWhite,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.auraStart,
              ),
          ],
        ),
      ),
    );
  }
}