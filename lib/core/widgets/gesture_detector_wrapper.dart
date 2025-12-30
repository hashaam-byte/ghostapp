// lib/core/widgets/gesture_detector_wrapper.dart
import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'package:flutter/services.dart';

enum SwipeDirection { left, right, up, down, none }

class GhostGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Function(SwipeDirection)? onSwipe;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;

  const GhostGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipe,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  @override
  State<GhostGestureDetector> createState() => _GhostGestureDetectorState();
}

class _GhostGestureDetectorState extends State<GhostGestureDetector> {
  Offset? _startPosition;
  DateTime? _tapDownTime;

  @override
  Widget build(BuildContext context) {
    final threshold = Responsive.gestureThreshold(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      
      // Tap
      onTap: widget.onTap,
      
      // Double tap
      onDoubleTap: widget.onDoubleTap,
      
      // Long press
      onLongPress: widget.onLongPress,
      
      // Swipe detection
      onPanStart: (details) {
        _startPosition = details.globalPosition;
        _tapDownTime = DateTime.now();
      },
      
      onPanEnd: (details) {
        if (_startPosition == null) return;
        
        final velocity = details.velocity.pixelsPerSecond;
        final dx = velocity.dx;
        final dy = velocity.dy;
        
        // Check if it's a fast swipe (not a drag)
        final speed = velocity.distance;
        if (speed < 300) return; // Too slow to be a swipe
        
        // Determine direction
        SwipeDirection direction = SwipeDirection.none;
        
        if (dx.abs() > dy.abs()) {
          // Horizontal swipe
          if (dx > 0) {
            direction = SwipeDirection.right;
            widget.onSwipeRight?.call();
          } else {
            direction = SwipeDirection.left;
            widget.onSwipeLeft?.call();
          }
        } else {
          // Vertical swipe
          if (dy > 0) {
            direction = SwipeDirection.down;
            widget.onSwipeDown?.call();
          } else {
            direction = SwipeDirection.up;
            widget.onSwipeUp?.call();
          }
        }
        
        widget.onSwipe?.call(direction);
        
        _startPosition = null;
        _tapDownTime = null;
      },
      
      child: widget.child,
    );
  }
}

// Pre-configured gesture zones for common GhostX patterns
class GhostGestureZone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onGhostTap;
  final VoidCallback? onGhostHold;
  final VoidCallback? onNavigateChat;
  final VoidCallback? onNavigateWorld;
  final VoidCallback? onShowActions;
  final VoidCallback? onDismiss;

  const GhostGestureZone({
    super.key,
    required this.child,
    this.onGhostTap,
    this.onGhostHold,
    this.onNavigateChat,
    this.onNavigateWorld,
    this.onShowActions,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GhostGestureDetector(
      onTap: onGhostTap,
      onLongPress: onGhostHold,
      onSwipeLeft: onNavigateChat,
      onSwipeRight: onNavigateWorld,
      onSwipeUp: onShowActions,
      onSwipeDown: onDismiss,
      child: child,
    );
  }
}

// Haptic feedback helper
class GhostHaptics {
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic not available: $e');
    }
  }

  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic not available: $e');
    }
  }

  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic not available: $e');
    }
  }

  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic not available: $e');
    }
  }
}

