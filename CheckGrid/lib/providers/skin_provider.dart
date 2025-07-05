import 'package:flutter/material.dart';

enum Skin {
  white(0, 0),
  black(1, 4.99),
  blue(2, 9.99);

  final int id;
  final double price;
  // final String description

  const Skin(this.id, this.price);

  String get name => toString().split('.').last;

  double get getPrice => price;
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
