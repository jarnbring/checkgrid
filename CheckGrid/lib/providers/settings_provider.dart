import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkgrid/providers/noti_service.dart';

class SettingsProvider extends ChangeNotifier {
  // Default settings
  bool _isBoldText = false;
  bool _isDarkMode = true;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _notificationReminder = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  bool get isBoldText => _isBoldText;
  bool get isDarkMode => _isDarkMode;
  bool get isVibrationOn => _isVibrationOn;
  bool get isSoundOn => _isSoundOn;
  bool get notificationReminder => _notificationReminder;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isBoldText = prefs.getBool('isBoldText') ?? false;
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _isVibrationOn = prefs.getBool('isVibrationOn') ?? true;
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _notificationReminder = prefs.getBool('notificationReminder') ?? true;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isBoldText', _isBoldText);
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setBool('isVibrationOn', _isVibrationOn);
      await prefs.setBool('isSoundOn', _isSoundOn);
      await prefs.setBool('notificationReminder', _notificationReminder);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> setBoldText(bool value) async {
    _isBoldText = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setVibration(bool value) async {
    _isVibrationOn = value;
    await _saveSettings();
    notifyListeners();
  }

  void doVibration(int impact) {
    if (!isVibrationOn) {
      return;
    }
    switch (impact) {
      case 1:
        HapticFeedback.lightImpact();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        break;
      case 3:
        HapticFeedback.heavyImpact();
        break;
      case 4:
        HapticFeedback.vibrate();
        break;
    }
  }

  Future<void> setSound(bool value) async {
    _isSoundOn = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setNotificationReminder(bool value) async {
    // Optimistically set
    _notificationReminder = value;
    await _saveSettings();
    notifyListeners();

    final notiService = NotiService();
    await notiService.initNotification();

    if (value) {
      // If enabling, ensure OS permission exists
      final allowed = await notiService.hasPermission() || await notiService.requestPermission();
      if (!allowed) {
        // Revert the toggle and ask user to open settings
        _notificationReminder = false;
        await _saveSettings();
        notifyListeners();
        await notiService.openSystemSettings();
        return;
      }
      // With permission granted, set up notifications
      await notiService.setupAppNotifications(this);
    } else {
      // Disable notifications
      await notiService.cancelAllNotifications();
    }
  }
}
