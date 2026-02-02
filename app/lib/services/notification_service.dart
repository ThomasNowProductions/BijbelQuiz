import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijbelquiz/l10n/strings_nl.dart' as strings;
import 'package:bijbelquiz/services/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Map<String, dynamic>? _motivationalMessages;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (kIsWeb) {
      AppLogger.info('Web platform detected - notifications not available');
      return;
    }

    if (Platform.isLinux) {
      AppLogger.info('Linux platform detected - notifications not available');
      _initialized = false;
      return;
    }

    try {
      AppLogger.info('Initializing NotificationService...');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      await _loadMotivationalMessages();
      tz_data.initializeTimeZones();
      _initialized = true;
      AppLogger.info('NotificationService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize NotificationService: $e');
      _initialized = false;
    }
  }

  Future<void> _loadMotivationalMessages() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/motivational_messages.json');
      _motivationalMessages = json.decode(jsonString);
      AppLogger.info('Motivational messages loaded successfully');
    } catch (e) {
      AppLogger.error('Failed to load motivational messages: $e');
      _motivationalMessages = {};
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) return;

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();

      AppLogger.info('Notification permission granted: ${granted ?? false}');

      if (Platform.isIOS) {
        final bool? iosGranted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        AppLogger.info('iOS notification permission granted: $iosGranted');
      }
    } catch (e) {
      AppLogger.error('Failed to request notification permissions: $e');
    }
  }

  Future<void> scheduleMotivationalNotifications({
    required bool enabled,
    int minNotificationsPerDay = 1,
    int maxNotificationsPerDay = 3,
    int startHour = 6,
    int startMinute = 0,
    int endHour = 23,
    int endMinute = 0,
  }) async {
    if (kIsWeb || !_initialized) return;

    try {
      await _notificationsPlugin.cancelAll();

      if (!enabled) {
        AppLogger.info(
            'Motivational notifications disabled, all notifications cancelled');
        return;
      }

      await requestPermissions();

      final prefs = await SharedPreferences.getInstance();
      final String language = prefs.getString('language') ?? 'nl';
      final Random random = Random();

      final int notificationsCount = minNotificationsPerDay +
          random.nextInt(maxNotificationsPerDay - minNotificationsPerDay + 1);

      final now = DateTime.now();
      final tz.TZDateTime nowTz = tz.TZDateTime.now(tz.local);

      AppLogger.info(
          'Scheduling $notificationsCount motivational notifications for ${now.toIso8601String().split('T')[0]}');

      for (int i = 0; i < notificationsCount; i++) {
        final tz.TZDateTime scheduledTime = _calculateRandomTime(
          nowTz,
          startHour,
          startMinute,
          endHour,
          endMinute,
        );

        final String message = _getMotivationalMessage(
          language,
          scheduledTime.hour,
        );

        await _scheduleNotification(
          id: 1000 + i,
          title: strings.AppStrings.appName,
          body: message,
          scheduledTime: scheduledTime,
        );

        AppLogger.info(
            'Scheduled notification #${i + 1} at ${scheduledTime.toLocal()}: $message');
      }

      final String todayDateString = now.toIso8601String().split('T')[0];
      await prefs.setString('last_notification_schedule_date', todayDateString);
    } catch (e) {
      AppLogger.error('Failed to schedule motivational notifications: $e');
    }
  }

  tz.TZDateTime _calculateRandomTime(
    tz.TZDateTime now,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
  ) {
    final Random random = Random();
    final startTotalMinutes = startHour * 60 + startMinute;
    final endTotalMinutes = endHour * 60 + endMinute;
    final totalMinutesRange = endTotalMinutes - startTotalMinutes;

    // Validate and normalize the time range
    if (totalMinutesRange < 0) {
      throw ArgumentError(
          'End time must be after start time. Got start: $startHour:$startMinute, end: $endHour:$endMinute');
    }

    // If start and end times are the same, return exact time
    if (totalMinutesRange == 0) {
      return tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );
    }

    // Random time between start and end (exclusive of end)
    final randomMinutes = startTotalMinutes + random.nextInt(totalMinutesRange);

    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      randomMinutes ~/ 60,
      randomMinutes % 60,
    );
  }

  String _getMotivationalMessage(String language, int hour) {
    try {
      if (_motivationalMessages == null) {
        return language == 'en'
            ? 'Test your Bible knowledge!'
            : 'Test je Bijbelkennis!';
      }

      final Map<String, dynamic> langData =
          _motivationalMessages!['motivational'][language] ??
              _motivationalMessages!['motivational']['nl'];
      List<String> messages;

      if (hour >= 6 && hour < 12) {
        messages = List<String>.from(langData['morning']);
      } else if (hour >= 12 && hour < 17) {
        messages = List<String>.from(langData['afternoon']);
      } else if (hour >= 17 && hour < 22) {
        messages = List<String>.from(langData['evening']);
      } else {
        messages = List<String>.from(langData['general']);
      }

      if (messages.isEmpty) {
        messages = List<String>.from(langData['general']);
      }

      final Random random = Random();
      return messages[random.nextInt(messages.length)];
    } catch (e) {
      AppLogger.error('Failed to get motivational message: $e');
      return language == 'en'
          ? 'Test your Bible knowledge!'
          : 'Test je Bijbelkennis!';
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'motivational_channel',
        'Motivational Messages',
        channelDescription: 'Daily motivational Bible quiz reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.error('Failed to schedule notification: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    try {
      await _notificationsPlugin.cancelAll();
      AppLogger.info('All notifications cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel all notifications: $e');
    }
  }

  Future<bool> checkAndScheduleDailyNotifications() async {
    if (kIsWeb || !_initialized) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final bool enabled =
          prefs.getBool('motivational_notifications_enabled') ?? true;

      final now = DateTime.now();
      final String todayDateString = now.toIso8601String().split('T')[0];

      // Check for old int-based format and migrate
      String? lastScheduledDateString =
          prefs.getString('last_notification_schedule_date');

      if (lastScheduledDateString == null) {
        final int? oldScheduledDay =
            prefs.getInt('last_notification_schedule_date');
        if (oldScheduledDay != null) {
          // Migration: old format was just the day (1-31)
          // We can't determine the exact date, so just update to new format
          // and allow scheduling today
          lastScheduledDateString = null;
          await prefs.remove('last_notification_schedule_date');
          AppLogger.info(
              'Migrated old int-based notification date format to string format');
        }
      }

      if (lastScheduledDateString != null &&
          lastScheduledDateString == todayDateString) {
        AppLogger.info('Notifications already scheduled for today, skipping');
        return false;
      }

      if (enabled) {
        await scheduleMotivationalNotifications(enabled: enabled);
        return true;
      }
    } catch (e) {
      AppLogger.error('Failed to check and schedule daily notifications: $e');
    }
    return false;
  }
}
