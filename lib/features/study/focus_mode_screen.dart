import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/ghost_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_client.dart';
import '../../core/config/api_config.dart';

class FocusModeScreen extends StatefulWidget {
  final int durationMinutes;
  final String mode; // 'focus', 'study', 'deep_work'
  
  const FocusModeScreen({
    super.key,
    this.durationMinutes = 25,
    this.mode = 'focus',
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> 
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPaused = false;
  bool _isActive = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
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

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Focus Complete!',
              style: TextStyle(
                color: AppTheme.ghostWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${widget.durationMinutes} XP earned',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close focus screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.auraStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                  child: const Text('Stay'),
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
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.mode.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.ghostWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Ghost with pulsing aura
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: const GhostWidget(
                        size: 100,
                        showAura: true,
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
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 3.seconds,
                      color: AppColors.auraStart.withOpacity(0.3),
                    ),

                const SizedBox(height: 16),

                // Progress text
                if (_isActive)
                  Text(
                    _isPaused ? 'Paused' : 'Stay focused...',
                    style: TextStyle(
                      color: AppTheme.ghostWhite.withOpacity(0.6),
                      fontSize: 18,
                    ),
                  ),

                const SizedBox(height: 40),

                // Progress ring
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
                      // Progress circle
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
                            backgroundColor: AppColors.auraStart,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Start Focus',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
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
                        Text(
                          'Apps are blocked during focus time',
                          style: TextStyle(
                            color: AppTheme.ghostWhite.withOpacity(0.4),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
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