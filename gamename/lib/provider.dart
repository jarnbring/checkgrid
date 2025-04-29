import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBoldText = false;
  bool _isDarkMode = false;
  bool _isVibrationOn = false;
  bool _isSoundOn = true;
  bool _notificationReminder = false;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isBoldText => _isBoldText;
  bool get isDarkMode => _isDarkMode;
  bool get isVibrationOn => _isVibrationOn;
  bool get isSoundOn => _isSoundOn;
  bool get notificationReminder => _notificationReminder;
  ThemeMode get themeMode => _themeMode;

  void setBoldText(bool value) {
    _isBoldText = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setVibration(bool value) {
    _isVibrationOn = value;
    notifyListeners();
  }

  void setSound(bool value) {
    _isSoundOn = value;
    notifyListeners();
  }

  void setNotificationReminder(bool value) {
    _notificationReminder = value;
    notifyListeners();
  }
}
