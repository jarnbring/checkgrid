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
  int rewardedAdsWatched = 19;

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
                      Skin.values.map((skin) {
                        final isUnlocked = skinProvider.unlockedSkins.contains(
                          skin,
                        );

                        return SkinItem(
                          skin: skin,
                          isUnlocked: isUnlocked,
                          onTap: () {
                            if (!isUnlocked) {
                              skinProvider.unlockSkin(skin);
                            }
                            context.read<SettingsProvider>().doVibration(1);
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),
                AdProgressBar(
                  adsRequired: adsRequiredForSkin,
                  rewardedAdsWatched: rewardedAdsWatched,
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
