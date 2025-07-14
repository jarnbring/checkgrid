import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
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
      debugPrint("Loading settings...");
      final prefs = await SharedPreferences.getInstance();
      _isBoldText = prefs.getBool('isBoldText') ?? false;
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _isVibrationOn = prefs.getBool('isVibrationOn') ?? true;
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _notificationReminder = prefs.getBool('notificationReminder') ?? true;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _isLoading = false;

      debugPrint("Settings loaded - isSoundOn: $_isSoundOn");
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSettings() async {
    try {
      debugPrint("Saving settings - isSoundOn: $_isSoundOn");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isBoldText', _isBoldText);
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setBool('isVibrationOn', _isVibrationOn);
      await prefs.setBool('isSoundOn', _isSoundOn);
      await prefs.setBool('notificationReminder', _notificationReminder);

      // Verifiera att värdet verkligen sparades
      final savedValue = prefs.getBool('isSoundOn');
      debugPrint("Verified saved isSoundOn: $savedValue");
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
    _notificationReminder = value;
    await _saveSettings();
    notifyListeners();
  }
}
