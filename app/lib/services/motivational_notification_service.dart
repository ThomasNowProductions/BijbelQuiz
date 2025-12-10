import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import '../services/logger.dart';

/// Motivational notification service for scheduling and sending daily motivational messages
class MotivationalNotificationService {
  static const String _channelId = 'motivational_channel';
  static const String _channelName = 'Motivational Notifications';
  static const String _channelDescription = 'Daily motivational messages to encourage Bible study';

  static const String _notificationGroup = 'motivational_notifications';
  static const String _backgroundTaskIdentifier = 'motivational_notification_task';

  late FlutterLocalNotificationsPlugin _flutterLocalNotifications;
  late AndroidNotificationDetails _androidNotificationDetails;
  bool _isInitialized = false;

  // Predefined motivational messages
  final List<String> _motivationalMessages = [
    '🌟 Start your day with God\'s word! Open BijbelQuiz and grow in faith.',
    '📖 Your Bible adventure awaits! Take a quiz and deepen your knowledge.',
    '💪 Strengthen your spiritual muscles today with a Bible quiz.',
    '🌈 Every question is a step closer to wisdom. Continue your journey!',
    '🎯 Your next breakthrough is just one quiz away!',
    '✨ Faith grows with practice. Take a quiz and watch yourself flourish!',
    '🗺️ Navigate through scripture and discover new insights today.',
    '🎪 The treasure of God\'s word is waiting for you!',
    '🚀 Ready to level up your Bible knowledge? Let\'s go!',
    '🌱 Today\'s quiz is tomorrow\'s wisdom. Keep growing!',
    '🏆 You\'re doing great! One more quiz to add to your victory.',
    '🔥 Ignite your faith with today\'s Scripture challenge!',
    '🎨 Paint your day with colors from the Bible!',
    '🎵 Read between the lines and sing with Scripture!',
    '⚡ Electrify your faith with a Bible quiz challenge!',
  ];

  MotivationalNotificationService() {
    _initializeNotifications();
  }

  /// Initialize the notification service
  void _initializeNotifications() {
    tz.initializeTimeZones();
    
    _flutterLocalNotifications = FlutterLocalNotificationsPlugin();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _androidNotificationDetails = const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      enableLights: true,
      groupKey: _notificationGroup,
      playSound: true,
      icon: '@mipmap/launcher_icon',
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Motivational notification tapped: ${response.payload}');
    
    // Track analytics if needed
    // You could add specific actions here like opening the app to a specific screen
  }

  /// Check and request notification permissions
  Future<bool> checkAndRequestPermission() async {
    try {
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        AppLogger.info('Notification permission granted');
        return true;
      } else if (status.isDenied || status.isPermanentlyDenied) {
        AppLogger.warning('Notification permission denied');
        return false;
      }
      
      return false;
    } catch (e) {
      AppLogger.error('Error checking notification permission', e);
      return false;
    }
  }

  /// Create notification channel for Android 8.0+
  Future<void> createNotificationChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _flutterLocalNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Schedule motivational notifications for a day
  Future<void> scheduleDailyMotivationalNotifications({bool? enabled}) async {
    try {
      // Check permission first
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        AppLogger.warning('No notification permission, cannot schedule notifications');
        return;
      }

      await createNotificationChannel();

      // Cancel any existing motivational notifications
      await _cancelAllNotifications();

      // If enabled is provided, use it; otherwise default to true
      final shouldSchedule = enabled ?? true;
      
      if (!shouldSchedule) {
        AppLogger.info('Motivational notifications are disabled, skipping scheduling');
        return;
      }

      // Get random times for 1-3 notifications between 6:00 AM and 11:00 PM
      final notificationTimes = _generateRandomTimes();
      
      AppLogger.info('Scheduling ${notificationTimes.length} motivational notifications for today');

      // Schedule each notification
      for (int i = 0; i < notificationTimes.length; i++) {
        final time = notificationTimes[i];
        final message = _getRandomMessage();
        
        await _scheduleNotificationAt(
          time: time,
          message: message,
          id: i + 1, // Use different IDs for each notification
        );
      }

      AppLogger.info('Successfully scheduled ${notificationTimes.length} motivational notifications');
    } catch (e) {
      AppLogger.error('Error scheduling motivational notifications', e);
    }
  }

  /// Generate random times for 1-3 notifications between 6:00 AM and 11:00 PM
  List<DateTime> _generateRandomTimes() {
    final random = Random();
    final count = random.nextInt(3) + 1; // 1-3 notifications
    
    // Convert 6:00 AM and 11:00 PM to minutes since midnight
    const startMinutes = 6 * 60; // 6:00 AM = 360 minutes
    const endMinutes = 23 * 60; // 11:00 PM = 1380 minutes

    final times = <DateTime>[];
    final usedMinutes = <int>{};

    for (int i = 0; i < count; i++) {
      int randomMinutes;
      
      // Ensure minimum 2-hour gap between notifications
      do {
        randomMinutes = startMinutes + random.nextInt(endMinutes - startMinutes);
      } while (usedMinutes.any((existing) => (existing - randomMinutes).abs() < 120));
      
      usedMinutes.add(randomMinutes);

      final hours = randomMinutes ~/ 60;
      final minutes = randomMinutes % 60;

      final now = DateTime.now();
      final notificationTime = DateTime(
        now.year,
        now.month,
        now.day,
        hours,
        minutes,
      );

      times.add(notificationTime);
    }

    // Sort times
    times.sort();
    return times;
  }

  /// Get a random motivational message
  String _getRandomMessage() {
    final random = Random();
    return _motivationalMessages[random.nextInt(_motivationalMessages.length)];
  }

  /// Schedule a notification at a specific time
  Future<void> _scheduleNotificationAt({
    required DateTime time,
    required String message,
    required int id,
  }) async {
    try {
      final now = DateTime.now();
      
      // If the time has passed today, schedule for tomorrow
      final scheduledTime = time.isBefore(now) ? time.add(const Duration(days: 1)) : time;

      await _flutterLocalNotifications.zonedSchedule(
        id,
        'BijbelQuiz Motivational Message',
        message,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: _androidNotificationDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      AppLogger.info('Scheduled notification for $scheduledTime with message: $message');
    } catch (e) {
      AppLogger.error('Error scheduling notification for $time', e);
      rethrow;
    }
  }

  /// Cancel all motivational notifications
  Future<void> _cancelAllNotifications() async {
    try {
      await _flutterLocalNotifications.cancelAll();
      AppLogger.info('Cancelled all motivational notifications');
    } catch (e) {
      AppLogger.error('Error cancelling motivational notifications', e);
    }
  }

  /// Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotifications.cancel(id);
      AppLogger.info('Cancelled motivational notification with ID: $id');
    } catch (e) {
      AppLogger.error('Error cancelling notification with ID: $id', e);
    }
  }

  /// Initialize background task for WorkManager
  static void initializeBackgroundTask() {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Background task callback
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      AppLogger.info('Background task executed: $task');
      
      switch (task) {
        case _backgroundTaskIdentifier:
          // This would be called to reschedule notifications (e.g., daily reset)
          // Implement logic to reschedule for the next day
          return Future.value(true);
        default:
          return Future.value(false);
      }
    });
  }

  /// Schedule background task for daily notification rescheduling
  Future<void> scheduleBackgroundTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        'daily-notification-reset',
        _backgroundTaskIdentifier,
        frequency: const Duration(hours: 24),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: true,
        ),
      );
      
      AppLogger.info('Background task scheduled for daily notification rescheduling');
    } catch (e) {
      AppLogger.error('Error scheduling background task', e);
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(bool enabled) async {
    if (enabled) {
      await scheduleDailyMotivationalNotifications();
    } else {
      await _cancelAllNotifications();
    }
  }

  /// Get next scheduled notification info (for testing/debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pendingNotifications = await _flutterLocalNotifications.pendingNotificationRequests();
      return pendingNotifications.where((notification) => 
        notification.id >= 1 && notification.id <= 3
      ).toList();
    } catch (e) {
      AppLogger.error('Error getting pending notifications', e);
      return [];
    }
  }
}