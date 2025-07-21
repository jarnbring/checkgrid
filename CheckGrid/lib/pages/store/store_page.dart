import 'package:checkgrid/pages/store/components/progress_bar.dart';
import 'package:checkgrid/pages/store/components/skin_item.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final int adsRequiredForSkin = 20;
  int rewardedAdsWatched = 2;

  @override
  Widget build(BuildContext context) {
    final skinProvider = context.watch<SkinProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Text("Store", style: TextStyle(fontSize: 30)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    spacing: 100,
                    children:
                        skinProvider.allSkins.map((skin) {
                          final isUnlocked = skinProvider.unlockedSkins
                              .contains(skin);
                          final watchedAds = skinProvider.getWatchedAds(skin);
                          final adsRequired = skin.adsRequired ?? 0;

                          // Remove the white skin because every user starts with it, should not be in the store!
                          //if (skin.id == 0) return const SizedBox.shrink();

                          return SkinItem(
                            skin: skin,
                            isUnlocked: isUnlocked,
                            onTap: () {
                              if (!isUnlocked) {
                                skinProvider.watchAdForSkin(skin, context);
                              } else {
                                skinProvider.selectSkin(skin);
                              }
                              context.read<SettingsProvider>().doVibration(1);
                            },
                            child:
                                skin.adsRequired != null
                                    ? AdProgressBar(
                                      adsRequired: adsRequired,
                                      rewardedAdsWatched: watchedAds,
                                    )
                                    : null,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 80),
                  const Text(
                    "More skins coming soon...",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 300),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
