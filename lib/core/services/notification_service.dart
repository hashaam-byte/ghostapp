// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    try {
      // Request notification permission
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint('Notification permission denied');
        return;
      }
      
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      _isInitialized = true;
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Notification init error: $e');
      _isInitialized = false;
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }
  
  Future<void> showGhostSuggestion({
    required String title,
    required String message,
    String? action,
  }) async {
    if (!_isInitialized) return;
    
    const androidDetails = AndroidNotificationDetails(
      'ghost_suggestions',
      'Ghost Suggestions',
      channelDescription: 'Smart suggestions from your Ghost',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFA020F0),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      message,
      details,
      payload: action,
    );
  }
  
  Future<void> showQuestComplete({
    required String questTitle,
    required int xpEarned,
  }) async {
    await showGhostSuggestion(
      title: '🎉 Quest Complete!',
      message: '$questTitle (+$xpEarned XP)',
      action: 'view_quests',
    );
  }
  
  Future<void> showLevelUp({
    required int newLevel,
  }) async {
    await showGhostSuggestion(
      title: '🚀 Level Up!',
      message: 'You reached Level $newLevel!',
      action: 'view_profile',
    );
  }
  
  Future<void> showStreakReminder() async {
    await showGhostSuggestion(
      title: '🔥 Don\'t Break Your Streak!',
      message: 'Complete one task to keep your streak going',
      action: 'view_tasks',
    );
  }
  
  Future<void> showFocusReminder({
    required int distractionMinutes,
  }) async {
    await showGhostSuggestion(
      title: '👻 Ghost here',
      message: 'You\'ve been distracted for $distractionMinutes mins. Want to focus?',
      action: 'start_focus',
    );
  }
  
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String message,
  }) async {
    if (!_isInitialized) return;
    
    // TODO: Implement scheduled notifications
    // This requires timezone package and proper scheduling
    debugPrint('Schedule reminder at $hour:$minute - $message');
  }
  
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}