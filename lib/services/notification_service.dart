import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);

      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      _initialized = true;
      debugPrint('NotificationService initialized v17');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> scheduleDailySleepReminder() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    try {
      await _plugin.zonedSchedule(
        1,
        '🌙 Good Morning!',
        'Don\'t forget to log last night\'s sleep in SleepWell',
        _nextInstanceOf(8, 00),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sleep_reminder',
            'Sleep Reminders',
            channelDescription: 'Daily reminders to log your sleep',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', true);
      debugPrint('Daily reminder scheduled for 8:00 AM');
    } catch (e) {
      debugPrint('scheduleDailySleepReminder error: $e');
    }
  }

  Future<void> scheduleWeeklyReport() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    try {
      await _plugin.zonedSchedule(
        2,
        '📊 Your Weekly Sleep Report is Ready!',
        'See how you slept this week and get personalized tips',
        _nextMonday(9, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_report',
            'Weekly Reports',
            channelDescription: 'Weekly sleep report notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      debugPrint('Weekly report scheduled for Monday 9:00 AM');
    } catch (e) {
      debugPrint('scheduleWeeklyReport error: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    try {
      await _plugin.zonedSchedule(
        0,
        '🔔 SleepWell Notifications Active!',
        'You\'ll get a reminder daily to log your sleep',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('Test notification scheduled for 10 seconds!');
    } catch (e) {
      debugPrint('showTestNotification error: $e');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextMonday(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    if (daysUntilMonday == 0) daysUntilMonday = 7;
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntilMonday,
      hour,
      minute,
    );
  }
}
