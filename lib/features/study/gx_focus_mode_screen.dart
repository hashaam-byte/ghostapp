// lib/features/study/gx_focus_mode_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/gx_aura_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_client.dart';

class GXFocusModeScreen extends StatefulWidget {
  final int durationMinutes;
  final String mode; // 'focus', 'study', 'deep_work'
  
  const GXFocusModeScreen({
    super.key,
    this.durationMinutes = 25,
    this.mode = 'focus',
  });

  @override
  State<GXFocusModeScreen> createState() => _GXFocusModeScreenState();
}

class _GXFocusModeScreenState extends State<GXFocusModeScreen> 
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;
  bool _isActive = false;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _startFocus() {
    setState(() => _isActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0 && !_isPaused) {
          _remainingSeconds--;
        } else if (_remainingSeconds == 0) {
          _completeFocus();
        }
      });
    });
  }

  void _pauseFocus() {
    setState(() => _isPaused = !_isPaused);
  }

  void _stopFocus() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  Future<void> _completeFocus() async {
    _timer?.cancel();
    
    // Award XP
    try {
      await ApiClient.post(
        '/xp/award',
        data: {
          'amount': widget.durationMinutes,
          'reason': 'focus_session_complete',
          'category': widget.mode,
        },
      );
    } catch (e) {
      debugPrint('Failed to award XP: $e');
    }

    if (!mounted) return;

    // Show completion celebration
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppColors.ghostAuraGradient,
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
              const Text('🎉', style: TextStyle(fontSize: 80))
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text(
                'Focus Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                '+${widget.durationMinutes} XP earned',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close focus screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.auraStart,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms).scale(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getModeLabel() {
    switch (widget.mode) {
      case 'study':
        return 'STUDY MODE';
      case 'deep_work':
        return 'DEEP WORK';
      default:
        return 'FOCUS MODE';
    }
  }

  String _getModeEmoji() {
    switch (widget.mode) {
      case 'study':
        return '📚';
      case 'deep_work':
        return '🎯';
      default:
        return '⚡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / (widget.durationMinutes * 60));

    return WillPopScope(
      onWillPop: () async {
        if (_isActive) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Exit Focus Mode?',
                style: TextStyle(color: AppTheme.ghostWhite),
              ),
              content: const Text(
                'Your progress will be lost.',
                style: TextStyle(color: AppTheme.ghostWhite),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay Focused'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GradientBackground(
          blur: 30,
          darken: 0.5,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!_isActive)
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: AppTheme.ghostWhite,
                          onPressed: _stopFocus,
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.ghostAuraGradient,
                          borderRadius: BorderRadius.circular(20),
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
                            Text(_getModeEmoji(), style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              _getModeLabel(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Aura with pulsing effect
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: const GXAuraWidget(
                        size: 100,
                        showParticles: true,
                        isAnimated: false,
                        mood: 'focused',
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Timer
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    color: AppTheme.ghostWhite,
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 4,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 3.seconds,
                      color: AppColors.auraStart.withOpacity(0.3),
                    ),

                const SizedBox(height: 16),

                // Status text
                if (_isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isPaused 
                          ? AppColors.warning.withOpacity(0.2)
                          : AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isPaused 
                            ? AppColors.warning.withOpacity(0.5)
                            : AppColors.success.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      _isPaused ? '⏸ Paused' : '🎯 Stay focused...',
                      style: TextStyle(
                        color: _isPaused ? AppColors.warning : AppColors.success,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      .animate(
                        key: ValueKey(_isPaused),
                      )
                      .fadeIn(duration: 300.ms)
                      .scale(),

                const SizedBox(height: 40),

                // Progress circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    children: [
                      // Background circle
                      Center(
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 4,
                            ),
                          ),
                        ),
                      ),
                      // Progress circle with rotation
                      Center(
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.auraStart,
                            ),
                          ),
                        ),
                      ),
                      // Center completion percentage
                      Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: AppTheme.ghostWhite.withOpacity(0.6),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Controls
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (!_isActive)
                        // Start button
                        ElevatedButton(
                          onPressed: _startFocus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppColors.ghostAuraGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.auraStart.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                minHeight: 56,
                              ),
                              child: const Text(
                                'Start Focus',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(delay: 200.ms)
                      else
                        // Active controls
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pauseFocus,
                                icon: Icon(
                                  _isPaused ? Icons.play_arrow : Icons.pause,
                                ),
                                label: Text(_isPaused ? 'Resume' : 'Pause'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  foregroundColor: AppTheme.ghostWhite,
                                  minimumSize: const Size(0, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _stopFocus,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error.withOpacity(0.2),
                                foregroundColor: AppColors.error,
                                minimumSize: const Size(56, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Tip
                      if (_isActive)
                        Container(
                          padding: const EdgeInsets.all(12),
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
                                Icons.info_outline,
                                color: AppColors.auraStart,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Distracting apps are blocked',
                                  style: TextStyle(
                                    color: AppTheme.ghostWhite.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }
}