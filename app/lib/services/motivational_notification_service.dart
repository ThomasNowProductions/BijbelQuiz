import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:workmanager/workmanager.dart';
import 'logger.dart';
import 'motivational_messages.dart';

const String _notificationTaskId = 'motivational_notification_task';

/// Service to manage motivational notifications
class MotivationalNotificationService {
  static final MotivationalNotificationService _instance =
      MotivationalNotificationService._internal();

  factory MotivationalNotificationService() => _instance;
  MotivationalNotificationService._internal();

  static const String _enabledKey = 'motivational_notifications_enabled';
  static const int _notificationId = 42;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _isEnabled = true;

  /// Initialize the notification service
  Future<void> initialize({required String languageCode}) async {
    if (_isInitialized) return;

    try {
      AppLogger.info('Initializing MotivationalNotificationService...');

      // Initialize timezone data
      tz_data.initializeTimeZones();

      // Initialize FlutterLocalNotifications
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android initialization
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      final iosInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          AppLogger.info('iOS notification received: $title - $body');
        },
      );

      final initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          AppLogger.info(
              'Notification tapped with payload: ${response.payload}');
        },
      );

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Load enabled state
      _isEnabled = _prefs?.getBool(_enabledKey) ?? true;

      // Initialize WorkManager for background scheduling
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: !kReleaseMode,
      );

      AppLogger.info(
          'MotivationalNotificationService initialized successfully (enabled: $_isEnabled)');
      _isInitialized = true;

      // Schedule notifications if enabled
      if (_isEnabled) {
        await scheduleNotifications(languageCode: languageCode);
      }
    } catch (e) {
      AppLogger.error('Failed to initialize MotivationalNotificationService', e);
      rethrow;
    }
  }

  /// Enable or disable motivational notifications
  Future<void> setEnabled(bool enabled, {required String languageCode}) async {
    try {
      if (enabled == _isEnabled) return;

      _isEnabled = enabled;
      await _prefs?.setBool(_enabledKey, enabled);

      if (enabled) {
        AppLogger.info('Enabling motivational notifications');
        await scheduleNotifications(languageCode: languageCode);
      } else {
        AppLogger.info('Disabling motivational notifications');
        await cancelAllNotifications();
      }

      AppLogger.info('Motivational notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      AppLogger.error('Failed to set notification enabled state', e);
      rethrow;
    }
  }

  /// Check if notifications are enabled
  bool get isEnabled => _isEnabled;

  /// Schedule daily motivational notifications
  Future<void> scheduleNotifications({required String languageCode}) async {
    try {
      if (!_isInitialized) {
        AppLogger.warning(
            'Attempted to schedule notifications before initialization');
        return;
      }

      AppLogger.info('Scheduling motivational notifications...');

      // Cancel any existing scheduled notifications
      await Workmanager().cancelByUniqueName(_notificationTaskId);

      // Schedule 1-3 random notifications per day
      final notificationCount = Random().nextInt(3) + 1; // 1 to 3

      for (int i = 0; i < notificationCount; i++) {
        final scheduledTime = _getRandomNotificationTime();

        AppLogger.info(
            'Scheduling notification $i at ${scheduledTime.hour}:${scheduledTime.minute}');

        // Calculate delay until first notification
        final now = DateTime.now();
        final delay = scheduledTime.difference(now);

        // Only schedule if time is in the future
        if (delay.isNegative) {
          AppLogger.info(
              'Scheduled time is in the past, will schedule for tomorrow');
          final tomorrowTime = scheduledTime.add(const Duration(days: 1));
          final tomorrowDelay = tomorrowTime.difference(now);

          await Workmanager().registerPeriodicTask(
            '$_notificationTaskId-$i',
            _notificationTaskId,
            frequency: const Duration(days: 1),
            initialDelay: tomorrowDelay,
            constraints: Constraints(
              networkType: NetworkType.not_required,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresDeviceIdle: false,
              requiresStorageNotLow: false,
            ),
            backoffPolicy: BackoffPolicy.exponential,
            backoffPolicyDelay: const Duration(minutes: 15),
            tag: '$_notificationTaskId-tag-$i',
          );
        } else {
          // Schedule first notification for today
          await Workmanager().registerPeriodicTask(
            '$_notificationTaskId-$i',
            _notificationTaskId,
            frequency: const Duration(days: 1),
            initialDelay: delay,
            constraints: Constraints(
              networkType: NetworkType.not_required,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresDeviceIdle: false,
              requiresStorageNotLow: false,
            ),
            backoffPolicy: BackoffPolicy.exponential,
            backoffPolicyDelay: const Duration(minutes: 15),
            tag: '$_notificationTaskId-tag-$i',
          );
        }
      }

      AppLogger.info(
          'Scheduled $notificationCount motivational notifications for today');
    } catch (e) {
      AppLogger.error('Failed to schedule notifications', e);
      rethrow;
    }
  }

  /// Send a notification immediately
  Future<void> sendNotification({required String languageCode}) async {
    try {
      if (!_isInitialized) {
        AppLogger.warning('Attempted to send notification before initialization');
        return;
      }

      final message = MotivationalMessages.getRandomMessage(languageCode);

      const androidDetails = AndroidNotificationDetails(
        'bijbelquiz_motivational',
        'Motivational Notifications',
        channelDescription: 'Daily motivational messages to inspire Bible learning',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      const iosDetails = DarwinNotificationDetails(
        sound: 'notification.caf',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        _notificationId,
        'BibleQuiz Inspiration',
        message,
        notificationDetails,
        payload: 'open_app',
      );

      AppLogger.info('Motivational notification sent: $message');
    } catch (e) {
      AppLogger.error('Failed to send notification', e);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      await Workmanager().cancelAll();
      AppLogger.info('All notifications cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel notifications', e);
      rethrow;
    }
  }

  /// Get a random time between 6 AM and 11 PM
  DateTime _getRandomNotificationTime() {
    final now = DateTime.now();
    final minHour = 6;
    final maxHour = 23;
    final randomHour =
        minHour + Random().nextInt(maxHour - minHour); // 6-22 (6 AM to 10 PM)
    final randomMinute = Random().nextInt(60); // 0-59 minutes

    return DateTime(now.year, now.month, now.day, randomHour, randomMinute);
  }

  /// Dispose the service
  void dispose() {
    AppLogger.info('Disposing MotivationalNotificationService');
    _isInitialized = false;
  }
}

/// Callback dispatcher for WorkManager background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == _notificationTaskId) {
        final service = MotivationalNotificationService();
        
        // Get language from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final language = prefs.getString('language') ?? 'nl';
        
        // Initialize if needed (will check if already initialized)
        await service.initialize(languageCode: language);
        
        // Send the notification
        await service.sendNotification(languageCode: language);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Failed to execute background notification task', e);
      return false;
    }
  });
}
