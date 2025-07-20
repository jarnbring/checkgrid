import 'package:flutter/material.dart';

enum Skin {
  white(0, 0, false),
  black(1, 4.99, true);
  //blue(2, 9.99, true);

  final int id;
  final double price;
  final bool isNew;
  // final String description

  const Skin(this.id, this.price, this.isNew);

  // Getters
  String get name => toString().split('.').last;
  double get getPrice => price;
  bool get getIsNew => isNew;
}

class SkinProvider with ChangeNotifier {
  final List<Skin> allSkins = Skin.values;

  Skin selectedSkin = Skin.white;

  List<Skin> unlockedSkins = [Skin.white];

  List<Skin> get unlockedSkinsList => unlockedSkins;

  void selectSkin(Skin skin) {
    if (unlockedSkins.contains(skin)) {
      selectedSkin = skin;
      notifyListeners();
    }
  }

  void unlockSkin(Skin skin) {
    if (!unlockedSkins.contains(skin)) {
      unlockedSkins = List.from(unlockedSkins)..add(skin);
      notifyListeners();
    }
  }
}
