import 'package:flutter/material.dart';

class SkinProvider with ChangeNotifier {
  final Map<String, int> allSkins = {'white': 0, 'black': 1, 'blue': 2};

  String selectedSkin = 'white';

  List<String> unlockedSkins = ['white'];

  List<MapEntry<String, int>> get unlockedSkinsEntries =>
      allSkins.entries.where((e) => unlockedSkins.contains(e.key)).toList();

  void selectSkin(String skinKey) {
    if (allSkins.containsKey(skinKey) && unlockedSkins.contains(skinKey)) {
      selectedSkin = skinKey;
      notifyListeners();
    }
  }

  void unlockSkin(String skinName) {
    if (!unlockedSkins.contains(skinName)) {
      unlockedSkins = List.from(unlockedSkins)..add(skinName);
      notifyListeners();
    }
  }
}
