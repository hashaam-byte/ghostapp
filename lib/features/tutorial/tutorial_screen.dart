// lib/features/tutorial/interactive_tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/widgets/gesture_detector_wrapper.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class InteractiveTutorialScreen extends StatefulWidget {
  const InteractiveTutorialScreen({super.key});

  @override
  State<InteractiveTutorialScreen> createState() => _InteractiveTutorialScreenState();
}

class _InteractiveTutorialScreenState extends State<InteractiveTutorialScreen> {
  int _currentStep = 0;
  bool _stepCompleted = false;
  String _ghostMessage = 'Hey... I live here now.';
  
  final List<TutorialStep> _steps = [
    TutorialStep(
      instruction: 'Tap me to continue',
      ghostMessage: 'Hey... I live here now.',
      requiredGesture: GestureType.tap,
      xpReward: 5,
    ),
    TutorialStep(
      instruction: 'Try talking to me',
      ghostMessage: 'Tap me and speak.',
      requiredGesture: GestureType.tap,
      xpReward: 5,
    ),
    TutorialStep(
      instruction: 'Swipe down to see quick actions',
      ghostMessage: 'I can control your focus.',
      requiredGesture: GestureType.swipeDown,
      xpReward: 10,
    ),
    TutorialStep(
      instruction: 'Swipe right to see your tasks',
      ghostMessage: 'Let me help you stay organized.',
      requiredGesture: GestureType.swipeRight,
      xpReward: 10,
    ),
    TutorialStep(
      instruction: 'Hold me for more options',
      ghostMessage: 'I don\'t disappear.',
      requiredGesture: GestureType.longPress,
      xpReward: 15,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _ghostMessage = _steps[0].ghostMessage;
  }
  
  void _handleGesture(GestureType gesture) {
    if (_stepCompleted) return;
    
    final step = _steps[_currentStep];
    if (gesture == step.requiredGesture) {
      setState(() => _stepCompleted = true);
      
      GhostHaptics.medium();
      
      // Move to next step after delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_currentStep < _steps.length - 1) {
          setState(() {
            _currentStep++;
            _stepCompleted = false;
            _ghostMessage = _steps[_currentStep].ghostMessage;
          });
        } else {
          _completeTutorial();
        }
      });
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
    final progress = (_currentStep + 1) / _steps.length;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Progress bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(AppColors.auraStart),
                  minHeight: 3,
                ),
              ),
              
              // Main content
              Column(
                children: [
                  const Spacer(),
                  
                  // Ghost with gesture detection
                  GhostGestureZone(
                    onGhostTap: () => _handleGesture(GestureType.tap),
                    onGhostHold: () => _handleGesture(GestureType.longPress),
                    onNavigateChat: () => _handleGesture(GestureType.swipeRight),
                    onShowActions: () => _handleGesture(GestureType.swipeUp),
                    onDismiss: () => _handleGesture(GestureType.swipeDown),
                    child: GhostWidget(
                      size: 140,
                      showAura: true,
                      isAnimated: !_stepCompleted,
                      mood: _stepCompleted ? 'excited' : 'happy',
                    ),
                  )
                      .animate(
                        key: ValueKey(_currentStep),
                      )
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Ghost message
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.auraStart.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _ghostMessage,
                      style: const TextStyle(
                        color: AppTheme.ghostWhite,
                        fontSize: 18,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      .animate(
                        key: ValueKey('$_currentStep-message'),
                      )
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const Spacer(),
                  
                  // Instruction hint
                  if (!_stepCompleted)
                    Container(
                      margin: const EdgeInsets.only(bottom: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.auraStart.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.auraStart.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        step.instruction,
                        style: const TextStyle(
                          color: AppTheme.ghostWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .shimmer(
                          duration: 2.seconds,
                          color: Colors.white24,
                        ),
                  
                  // Success checkmark
                  if (_stepCompleted)
                    Container(
                      margin: const EdgeInsets.only(bottom: 48),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 32,
                      ),
                    )
                        .animate()
                        .scale(
                          duration: 300.ms,
                          curve: Curves.elasticOut,
                        ),
                ],
              ),
              
              // Skip button
              Positioned(
                top: 16,
                right: 16,
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
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final String instruction;
  final String ghostMessage;
  final GestureType requiredGesture;
  final int xpReward;
  
  TutorialStep({
    required this.instruction,
    required this.ghostMessage,
    required this.requiredGesture,
    required this.xpReward,
  });
}

enum GestureType {
  tap,
  longPress,
  swipeLeft,
  swipeRight,
  swipeUp,
  swipeDown,
}