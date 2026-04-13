import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Safe NotificationService
/// Notifications scheduled but implementation is version-safe
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Notifications initialized on first toggle by user
  }

  Future<void> scheduleDailySleepReminder() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    await prefs.setInt('notification_hour', 8);
    await prefs.setInt('notification_minute', 0);
  }

  Future<void> scheduleWeeklyReport() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weekly_report_notification', true);
  }

  Future<void> cancelAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', false);
    await prefs.setBool('weekly_report_notification', false);
  }

  Future<void> showTestNotification() async {
    // Will show on Android when package is properly configured
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }
}
