import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Meet Your Ghost',
      'description': 'I live here now.\nI\'m your AI companion.',
      'instruction': 'Tap me to continue',
      'action': 'tap',
    },
    {
      'title': 'I Can Talk',
      'description': 'Ask me anything.\nI\'m here to help.',
      'instruction': 'Swipe right →',
      'action': 'swipe_right',
    },
    {
      'title': 'Quick Actions',
      'description': 'I can control your focus.',
      'instruction': 'Swipe up ↑',
      'action': 'swipe_up',
    },
    {
      'title': 'I\'m Everywhere',
      'description': 'I don\'t disappear.\nI float over other apps.',
      'instruction': 'Tap to see',
      'action': 'tap',
    },
    {
      'title': 'You\'re Ready',
      'description': 'Let\'s get started.',
      'instruction': 'Tap to enter',
      'action': 'complete',
    },
  ];

  void _handleInteraction(String action) {
    if (action == _steps[_currentStep]['action']) {
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        _completeTutorial();
      }
    }
  }

  Future<void> _completeTutorial() async {
    await StorageService.setTutorialComplete(true);
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: GestureDetector(
            onTap: () => _handleInteraction('tap'),
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                _handleInteraction('swipe_right');
              }
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                _handleInteraction('swipe_up');
              }
            },
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: _completeTutorial,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: AppTheme.ghostWhite.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Ghost
                      GestureDetector(
                        onTap: () => _handleInteraction('tap'),
                        child: const GhostWidget(
                          size: 140,
                          showAura: true,
                          isAnimated: true, // was `animate: true`
                        )
                            .animate(
                              key: ValueKey(_currentStep),
                            )
                            .fadeIn(duration: 600.ms)
                            .scale(delay: 200.ms),
                      ),

                      const SizedBox(height: 48),

                      // Title
                      Text(
                        step['title'],
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      )
                          .animate(
                            key: ValueKey('title$_currentStep'),
                          )
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        step['description'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.ghostWhite.withOpacity(0.7),
                            ),
                        textAlign: TextAlign.center,
                      )
                          .animate(
                            key: ValueKey('desc$_currentStep'),
                          )
                          .fadeIn(duration: 600.ms, delay: 200.ms),

                      const Spacer(),

                      // Instruction
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.auraStart.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: AppColors.auraStart.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          step['instruction'],
                          style: const TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                          .animate(
                            key: ValueKey('inst$_currentStep'),
                            onPlay: (controller) => controller.repeat(),
                          )
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .shimmer(
                            duration: 2.seconds,
                            color: Colors.white24,
                          ),

                      const SizedBox(height: 40),

                      // Progress dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _steps.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentStep ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentStep
                                  ? AppColors.auraStart
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms),
                    ],
                  ),
                ),

                // Gesture hints (visual only)
                if (step['action'] == 'swipe_right')
                  Positioned(
                    right: 24,
                    top: MediaQuery.of(context).size.height / 2,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.ghostWhite.withOpacity(0.3),
                      size: 32,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 1.seconds)
                        .fadeOut(duration: 1.seconds),
                  ),

                if (step['action'] == 'swipe_up')
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Icon(
                        Icons.arrow_upward,
                        color: AppTheme.ghostWhite.withOpacity(0.3),
                        size: 32,
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fadeIn(duration: 1.seconds)
                          .fadeOut(duration: 1.seconds),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}