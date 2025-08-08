import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz show initializeTimeZones;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:math';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  // ignore: prefer_final_fields
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    // init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // prepare android init settings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // init the plugin
    await notificationsPlugin.initialize(initSettings);
  }

  // NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'weekly_channel_id',
        'Weekly Notifications',
        channelDescription: 'Weekly Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    required SettingsProvider settingsProvider,
  }) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  /*
  
  Schedule a notification at a specified time (e.g. 11pm)

  - hour (0-23)
  - minute (0-59)
  */

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required SettingsProvider settingsProvider,
  }) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    // Create a date/time for today at the specified hour/min
    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      notificationDetails(),

      // Android specific: Allow notification while device is in low-power mode
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      // Make notification repeat DAILY at same time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // Get a random notification message from the collection
  Map<String, String> _getRandomNotification() {
    final List<Map<String, String>> notificationMessages = [
      {"title": "CheckGrid", "body": "The score is not good enough!"},
      {"title": "CheckGrid", "body": "Take a 2‑minute break and play!"},
      {"title": "CheckGrid", "body": "Only brilliancies allowed"},
    ];

    final random = Random();
    return notificationMessages[random.nextInt(notificationMessages.length)];
  }

  // Schedule weekly rotating notifications
  Future<void> scheduleWeeklyRotatingNotifications(
    SettingsProvider settingsProvider, {
    int hour = 20, // Default time: 8 PM
    int minute = 0,
  }) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Get current date
    final now = tz.TZDateTime.now(tz.local);
    
    // Calculate next Monday (or today if it's Monday)
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final nextMonday = now.add(Duration(days: daysUntilMonday));
    
    // Schedule notification for next Monday at specified time
    final scheduleDate = tz.TZDateTime(
      tz.local,
      nextMonday.year,
      nextMonday.month,
      nextMonday.day,
      hour,
      minute,
    );

    // Get a random notification message
    final notification = _getRandomNotification();

    // Schedule the weekly notification
    await notificationsPlugin.zonedSchedule(
      100, // Unique ID for weekly notifications
      notification["title"]!,
      notification["body"]!,
      scheduleDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Schedule multiple weekly notifications with different messages
  Future<void> scheduleMultipleWeeklyNotifications(
    SettingsProvider settingsProvider, {
    int hour = 19,
    int minute = 20,
  }) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Get current date
    final now = tz.TZDateTime.now(tz.local);
    
    // Calculate next Monday
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final nextMonday = now.add(Duration(days: daysUntilMonday));

    // Schedule notifications for the next 4 weeks with different messages
    for (int week = 0; week < 4; week++) {
      final scheduleDate = tz.TZDateTime(
        tz.local,
        nextMonday.year,
        nextMonday.month,
        nextMonday.day + (week * 7),
        hour,
        minute,
      );

      final notification = _getRandomNotification();

      await notificationsPlugin.zonedSchedule(
        100 + week, // Unique IDs: 100, 101, 102, 103
        notification["title"]!,
        notification["body"]!,
        scheduleDate,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  // Check and reschedule notifications if needed
  Future<void> checkAndRescheduleNotifications(
    SettingsProvider settingsProvider,
  ) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    // Get pending notifications
    final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
    
    // If no weekly notifications are scheduled, schedule them
    if (pendingNotifications.isEmpty || 
        !pendingNotifications.any((notification) => notification.id >= 100)) {
      await scheduleWeeklyRotatingNotifications(settingsProvider);
    }
  }

  // Initialize and setup notifications for the app
  Future<void> setupAppNotifications(
    SettingsProvider settingsProvider,
  ) async {
    await settingsProvider.loadSettings();
    
    if (settingsProvider.notificationReminder) {
      // Schedule multiple weeks of notifications to ensure continuous coverage
      await scheduleMultipleWeeklyNotifications(settingsProvider);
    }
  }

  // Get current notification status
  Future<bool> hasActiveNotifications() async {
    final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.isNotEmpty;
  }
}
