import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz show initializeTimeZones;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // init the plugin
    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // Prompt once on first launch
  Future<void> promptForPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('askedNotificationPermission') ?? false;
    if (asked) return;

    await requestPermissionCrossPlatform();
    await prefs.setBool('askedNotificationPermission', true);
  }

  // Cross-platform permission request that ensures iOS registers notification capability in Settings
  Future<bool> requestPermissionCrossPlatform() async {
    if (Platform.isIOS) {
      final ios = notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      return granted;
    }
    // Android 13+
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Permissions helper (kept for diagnostics)
  Future<bool> hasPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      final ios = notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(alert: false, badge: false, sound: false) ?? false;
      return granted;
    }

    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    return requestPermissionCrossPlatform();
  }

  Future<void> openSystemSettings() async {
    await openAppSettings();
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

  // SHOW NOTIFICATION, used for testing
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

  // Schedule ONE weekly notification (repeats same weekday/time)
  Future<void> scheduleWeeklyRotatingNotifications(
    SettingsProvider settingsProvider, {
    int hour = 21,
    int minute = 25,
  }) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    // Cancel existing notifications first
    await cancelAllNotifications();

    // First run: today at given time (or +7 days if time already passed)
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 7));
    }

    // Random message
    final notification = _getRandomNotification();

    await notificationsPlugin.zonedSchedule(
      100,
      notification["title"]!,
      notification["body"]!,
      scheduleDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // Check and reschedule notifications if needed
  Future<void> checkAndRescheduleNotifications(
    SettingsProvider settingsProvider,
  ) async {
    await settingsProvider.loadSettings();
    if (!settingsProvider.notificationReminder) return;

    final pending = await notificationsPlugin.pendingNotificationRequests();
    if (pending.isEmpty || !pending.any((n) => n.id == 100)) {
      await scheduleWeeklyRotatingNotifications(settingsProvider);
    }
  }

  // Initialize and setup notifications for the app
  Future<void> setupAppNotifications(
    SettingsProvider settingsProvider,
  ) async {
    await settingsProvider.loadSettings();
    if (settingsProvider.notificationReminder) {
      await scheduleWeeklyRotatingNotifications(settingsProvider);
    }
  }

  Future<bool> hasActiveNotifications() async {
    final pendingNotifications = await notificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.isNotEmpty;
  }
}
