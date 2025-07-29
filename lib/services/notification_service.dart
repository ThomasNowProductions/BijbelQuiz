import 'package:flutter_local_notifications_plus/flutter_local_notifications_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'logger.dart';

/// A service to handle local notifications for the application.
///
/// This service is a singleton and provides methods to initialize notifications,
/// schedule daily reminders, and manage notification permissions.
class NotificationService {
  /// The single instance of the [NotificationService].
  static final NotificationService _instance = NotificationService._internal();

  /// Factory constructor to return the singleton instance.
  factory NotificationService() => _instance;

  /// Private internal constructor for the singleton.
  NotificationService._internal();

  /// The plugin instance used to manage notifications.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static void Function(String message)? onError;

  /// Initializes the notification service.
  ///
  /// This must be called before any other notification methods. It sets up
  /// the timezone database and initializes the plugin with platform-specific settings.
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    AppLogger.info('Initializing NotificationService');
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
    _initialized = true;
    AppLogger.info('NotificationService initialized');
  }

  /// Plant drie dagelijkse motivatie-meldingen op willekeurige tijden.
  Future<void> scheduleDailyMotivationNotifications() async {
    await cancelAllNotifications();

    if (kIsWeb) return;

    // Genereer 3 willekeurige tijden tussen 8:00 en 22:00 voor vandaag
    final now = DateTime.now();
    final random = Random(now.year * 10000 + now.month * 100 + now.day); // Seed voor reproduceerbaarheid per dag
    final List<TimeOfDay> times = [];
    final Set<int> usedMinutes = {};
    while (times.length < 3) {
      final hour = 8 + random.nextInt(15); // 8 tot 22
      final minute = random.nextInt(60);
      final totalMinutes = hour * 60 + minute;
      if (!usedMinutes.contains(totalMinutes)) {
        times.add(TimeOfDay(hour: hour, minute: minute));
        usedMinutes.add(totalMinutes);
      }
    }
    times.sort((a, b) => a.hour != b.hour ? a.hour - b.hour : a.minute - b.minute);

    final List<String> messages = [
      'Doe mee met een quiz! 🚀',
      'Neem een pauze en speel BijbelQuiz!',
      'Test je kennis met een Bijbelquiz!',
      'Daag jezelf uit met een quiz! 💡',
      'Vergroot je kennis—vraag voor vraag!',
      'Klaar voor een leuke Bijbeluitdaging?',
      'Houd je geest scherp met BijbelQuiz!',
      'Ontdek iets nieuws in de Bijbel!',
      'Blijf actief—speel BijbelQuiz!',
      'Een korte quiz fleurt je dag op!',
      'Test nu je Bijbelkennis!',
      'Hoeveel weet jij? Kom erachter!',
      'Leren is een reis—geniet van de quiz!',
    ];
    messages.shuffle(random);

    if (Platform.isLinux) {
      for (int i = 0; i < times.length; i++) {
        final now = DateTime.now();
        final target = DateTime(now.year, now.month, now.day, times[i].hour, times[i].minute);
        final delay = target.isAfter(now) ? target.difference(now) : Duration.zero;
        Future.delayed(delay, () {
          flutterLocalNotificationsPlugin.show(
            200 + i,
            'BijbelQuiz',
            messages[i],
            const NotificationDetails(linux: LinuxNotificationDetails()),
          );
        });
      }
      return;
    }

    try {
      for (int i = 0; i < times.length; i++) {
        await _scheduleDailyNotification(
          id: 100 + i,
          title: 'BijbelQuiz',
          body: messages[i],
          timeOfDay: times[i],
        );
      }
    } catch (e) {
      onError?.call('Kon meldingen niet plannen: ${e.toString()}');
    }
  }

  /// Schedules a single daily notification at a specific time.
  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay timeOfDay,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation_channel',
          'Motivation Notifications',
          channelDescription: 'Daily motivational reminders to play BijbelQuiz',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        linux: LinuxNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Requests notification permissions on platforms that require it (iOS, macOS, Android).
  ///
  /// Returns `true` if permissions are granted or not required, `false` otherwise.
  /// On Web and Linux, this method returns `true` as permissions are handled differently.
  static Future<bool> requestNotificationPermission() async {
    if (kIsWeb || Platform.isLinux) return true;
    try {
      final plugin = NotificationService().flutterLocalNotificationsPlugin;
      if (Platform.isAndroid) {
        final androidImplementation = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final granted = await androidImplementation.requestNotificationsPermission();
          return granted ?? true;
        }
      } else if (Platform.isIOS) {
        final iosImplementation = plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final granted = await iosImplementation.requestPermissions(alert: true, badge: true, sound: true);
          return granted ?? true;
        }
      } else if (Platform.isMacOS) {
        final macImplementation = plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
        if (macImplementation != null) {
          final granted = await macImplementation.requestPermissions(alert: true, badge: true, sound: true);
          return granted ?? true;
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }
} 