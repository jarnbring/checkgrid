import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/providers/settings_provider.dart';

class AudioProvider with ChangeNotifier {
  late AudioPlayer _player;
  bool _isInitialized = false;
  final SettingsProvider _settingsProvider;

  AudioProvider(this._settingsProvider) {
    initialize();
    _settingsProvider.addListener(notifyListeners);
  }

  Future<void> initialize() async {
    try {
      _player = AudioPlayer();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing audio: $e');
      _isInitialized = false;
    }
  }

  Future<void> playSound(String soundPath) async {
    if (!_settingsProvider.isSoundOn || !_isInitialized) return;

    try {
      debugPrint("Playing sound: $soundPath");
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playPlacePiece() async {
    await playSound('audio/place_piece/placepiece1.mp3');
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(notifyListeners);
    _player.dispose();
    super.dispose();
  }
}
