import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isBoldText = false;
  bool _isDarkMode = false;
  bool _isVibrationOn = false;
  bool _isSoundOn = true;
  bool _notificationReminder = true;
  bool _useGlossEffect = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isBoldText => _isBoldText;
  bool get isDarkMode => _isDarkMode;
  bool get isVibrationOn => _isVibrationOn;
  bool get isSoundOn => _isSoundOn;
  bool get notificationReminder => _notificationReminder;
  bool get useGlossEffect => _useGlossEffect;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isBoldText = prefs.getBool('isBoldText') ?? false;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isVibrationOn = prefs.getBool('isVibrationOn') ?? false;
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _notificationReminder = prefs.getBool('notificationReminder') ?? false;
      _useGlossEffect = prefs.getBool('useGlossEffect') ?? true;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;

      print('Loaded settings: isBoldText=$_isBoldText, isDarkMode=$_isDarkMode, '
          'isVibrationOn=$_isVibrationOn, isSoundOn=$_isSoundOn, '
          'notificationReminder=$_notificationReminder, useGlossEffect=$_useGlossEffect');
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
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
      await prefs.setBool('useGlossEffect', _useGlossEffect);
      print('Saved settings: isBoldText=$_isBoldText, isDarkMode=$_isDarkMode, '
          'isVibrationOn=$_isVibrationOn, isSoundOn=$_isSoundOn, '
          'notificationReminder=$_notificationReminder, useGlossEffect=$_useGlossEffect');
    } catch (e) {
      print('Error saving settings: $e');
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

  void setGlossEffect(bool value) {
    _useGlossEffect = value;
    _saveSettings();
    notifyListeners();
  }

    void toggleGlossEffect() {
    _useGlossEffect = !_useGlossEffect;
    _saveSettings();
    notifyListeners();
  }
}