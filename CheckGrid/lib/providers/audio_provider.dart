import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/providers/settings_provider.dart';

class AudioProvider with ChangeNotifier {
  late AudioPlayer _player;
  late Random _rng;
  bool _isInitialized = false;
  final SettingsProvider _settingsProvider;

  AudioProvider(this._settingsProvider) {
    initialize();
    _settingsProvider.addListener(notifyListeners);
  }

  Future<void> initialize() async {
    try {
      _player = AudioPlayer();
      _rng = Random();
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
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> playPlacePiece() async {
    final randomSound =
        PlacePieceSounds.values[_rng.nextInt(PlacePieceSounds.values.length)];

    await playSound(randomSound.soundPath);
  }

  Future<void> playPickUpPiece() async {
    await playSound('audio/pick_up/pick_up_piece.mp3');
  }

  Future<void> playGameOver() async {
    await playSound('audio/game_over.mp3');
  }

  Future<void> playNewGame() async {
    await playSound('audio/new_game.mp3');
  }

  Future<void> playOpenMenu() async {
    await playSound('audio/menu/open_menu.mp3');
  }

  // Future<void> playCloseMenu() async {
  //   await playSound('audio/menu/close_menu.mp3');
  // }

  @override
  void dispose() {
    _settingsProvider.removeListener(notifyListeners);
    _player.dispose();
    super.dispose();
  }
}

enum PlacePieceSounds {
  sound1('audio/place_piece/place_piece_1.mp3'),
  sound2('audio/place_piece/place_piece_2.mp3');

  const PlacePieceSounds(this.soundPath);
  final String soundPath;
}
