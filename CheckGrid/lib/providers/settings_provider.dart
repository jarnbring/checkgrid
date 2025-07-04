import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBoldText = false;
  bool _isDarkMode = true;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _notificationReminder = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isBoldText => _isBoldText;
  bool get isDarkMode => _isDarkMode;
  bool get isVibrationOn => _isVibrationOn;
  bool get isSoundOn => _isSoundOn;
  bool get notificationReminder => _notificationReminder;
  ThemeMode get themeMode => _themeMode;

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

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
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

  void setBoldText(bool value) {
    _isBoldText = value;
    _saveSettings();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }

  void setVibration(bool value) {
    _isVibrationOn = value;
    _saveSettings();
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

  void setSound(bool value) {
    _isSoundOn = value;
    _saveSettings();
    notifyListeners();
  }

  void setNotificationReminder(bool value) {
    _notificationReminder = value;
    _saveSettings();
    notifyListeners();
  }
}
