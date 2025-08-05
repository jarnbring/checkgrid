import 'package:checkgrid/providers/ad_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Skin {
  white(0, 0, null, false),
  black(1, 4.99, 15, true);
  //blue(2, 9.99, null, true);

  final int id;
  final double price;
  final int? adsRequired;
  final bool isNew;

  const Skin(this.id, this.price, this.adsRequired, this.isNew);

  // Getters
  String get name => toString().split('.').last;
  double get getPrice => price;
  bool get getIsNew => isNew;
}

class SkinProvider with ChangeNotifier {
  final List<Skin> allSkins = Skin.values;
  Skin selectedSkin = Skin.white;
  List<Skin> unlockedSkins = [Skin.white];

  final Map<String, int> _watchedAdsCache = {};
  bool _isInitialized = false;

  List<Skin> get unlockedSkinsList => unlockedSkins;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Ladda unlocked skins
    final unlockedSkinIds = prefs.getStringList('unlocked_skins') ?? ['white'];
    unlockedSkins =
        allSkins.where((skin) => unlockedSkinIds.contains(skin.name)).toList();

    // Säkerställ att white alltid är unlocked
    if (!unlockedSkins.contains(Skin.white)) {
      unlockedSkins.add(Skin.white);
    }

    // Ladda valt skin
    final selectedSkinName = prefs.getString('selected_skin') ?? 'white';
    final loadedSkin = allSkins.firstWhere(
      (skin) => skin.name == selectedSkinName,
      orElse: () => Skin.white,
    );

    // Säkerställ att det valda skinet är upplåst
    if (unlockedSkins.contains(loadedSkin)) {
      selectedSkin = loadedSkin;
    } else {
      selectedSkin = Skin.white;
    }

    // Ladda alla watched ads till cache
    _watchedAdsCache.clear();
    for (final skin in allSkins) {
      final key = 'watched_ads_${skin.name}';
      _watchedAdsCache[skin.name] = prefs.getInt(key) ?? 0;
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Snabb synkron access till watched ads (från cache)
  int getWatchedAds(Skin skin) {
    return _watchedAdsCache[skin.name] ?? 0;
  }

  // Uppdatera både cache och SharedPreferences
  Future<void> _updateWatchedAds(Skin skin, int watchedAds) async {
    // Uppdatera cache omedelbart (snabb UI-uppdatering)
    _watchedAdsCache[skin.name] = watchedAds;

    // Spara till disk asynkront (ingen väntan)
    _saveWatchedAdsToPrefs(skin, watchedAds);

    notifyListeners();
  }

  // Privat metod för att spara till SharedPreferences
  Future<void> _saveWatchedAdsToPrefs(Skin skin, int watchedAds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'watched_ads_${skin.name}';
      await prefs.setInt(key, watchedAds);
    } catch (e) {
      debugPrint('Error saving watched ads: $e');
    }
  }

  // Öka watched ads
  Future<void> incrementWatchedAds(Skin skin) async {
    final currentWatchedAds = getWatchedAds(skin);
    final newWatchedAds = currentWatchedAds + 1;

    await _updateWatchedAds(skin, newWatchedAds);

    // Kontrollera om skin ska låsas upp
    if (newWatchedAds >= (skin.adsRequired ?? 0) &&
        !unlockedSkins.contains(skin)) {
      await unlockSkin(skin);
    }
  }

  // Synkrona getters för UI (inga FutureBuilders behövs)
  double getSkinProgress(Skin skin) {
    if (skin.adsRequired == null) return 1.0;
    if (unlockedSkins.contains(skin)) return 1.0;

    final watchedAds = getWatchedAds(skin);
    return (watchedAds / skin.adsRequired!).clamp(0.0, 1.0);
  }

  int getRemainingAds(Skin skin) {
    if (skin.adsRequired == null) return 0;
    if (unlockedSkins.contains(skin)) return 0;

    final watchedAds = getWatchedAds(skin);
    return (skin.adsRequired! - watchedAds).clamp(0, skin.adsRequired!);
  }

  // Unlocking
  Future<void> unlockSkin(Skin skin) async {
    if (!unlockedSkins.contains(skin)) {
      unlockedSkins = List.from(unlockedSkins)..add(skin);
      await _saveUnlockedSkins();
      notifyListeners();
    }
  }

  Future<void> _saveUnlockedSkins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skinNames = unlockedSkins.map((skin) => skin.name).toList();
      await prefs.setStringList('unlocked_skins', skinNames);
    } catch (e) {
      debugPrint('Error saving unlocked skins: $e');
    }
  }

  // Uppdaterad selectSkin som sparar valet
  Future<void> selectSkin(Skin skin) async {
    if (unlockedSkins.contains(skin)) {
      selectedSkin = skin;
      await _saveSelectedSkin(skin);
      notifyListeners();
    }
  }

  // Ny privat metod för att spara valt skin
  Future<void> _saveSelectedSkin(Skin skin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_skin', skin.name);
    } catch (e) {
      debugPrint('Error saving selected skin: $e');
    }
  }

  // Uppdaterad watchAdForSkin
  Future<void> watchAdForSkin(Skin skin, BuildContext context) async {
    if (unlockedSkins.contains(skin)) return;
    if (skin.adsRequired == null) return;

    final watchedAds = getWatchedAds(skin); // Snabb cache-access
    if (watchedAds >= skin.adsRequired!) return;

    final adProvider = Provider.of<AdProvider>(context, listen: false);
    final adService = adProvider.rewardedAdService;

    adService.showAd(
      context: context,
      onUserEarnedReward: () async {
        await incrementWatchedAds(skin);
      },
      onAdDismissed: () {
        adService.loadAd();
      },
    );
  }

  // Batch-uppdateringar för bättre prestanda
  Future<void> batchUpdateWatchedAds(Map<Skin, int> updates) async {
    final prefs = await SharedPreferences.getInstance();

    // Uppdatera cache först
    for (final entry in updates.entries) {
      _watchedAdsCache[entry.key.name] = entry.value;
    }

    // Batch-spara till SharedPreferences
    final batch = <String, int>{};
    for (final entry in updates.entries) {
      batch['watched_ads_${entry.key.name}'] = entry.value;
    }

    // Spara alla på en gång
    for (final entry in batch.entries) {
      await prefs.setInt(entry.key, entry.value);
    }

    notifyListeners();
  }
}
