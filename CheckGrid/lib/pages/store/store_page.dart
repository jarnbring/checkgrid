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
        backgroundColor: Colors.transparent,
        title: const Text("Store", style: TextStyle(fontSize: 30)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 50,
                  runSpacing: 50,
                  children:
                      // Om koden redan är i en Consumer eller setState-kontext
                      skinProvider.allSkins.map((skin) {
                        final isUnlocked = skinProvider.unlockedSkins.contains(
                          skin,
                        );
                        final watchedAds = skinProvider.getWatchedAds(skin);
                        final adsRequired = skin.adsRequired ?? 0;

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
                          child: AdProgressBar(
                            adsRequired: adsRequired,
                            rewardedAdsWatched: watchedAds,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),

                const SizedBox(height: 500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
