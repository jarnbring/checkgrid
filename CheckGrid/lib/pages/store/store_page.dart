import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/pages/store/components/progress_bar.dart';
import 'package:checkgrid/pages/store/components/skin_item.dart';
import 'package:checkgrid/pages/store/components/standard_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final skinProvider = context.watch<SkinProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;
    int rewardedAdsWatched = 19;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedText(text: "Store", fontSize: 34),
                const SizedBox(height: 60),
                Wrap(
                  spacing: 60,
                  runSpacing: 60,
                  children: [
                    SkinItem(
                      skin: Skin.white,
                      isNew: false,
                      isUnlocked: false, // Fix here!
                      onTap: () {
                        // If is owned, show "Owned" text
                        // If equipped
                        if (!skinProvider.unlockedSkins.contains(Skin.white)) {
                          skinProvider.unlockSkin(Skin.white);
                        }
                      },
                    ),
                    SkinItem(
                      skin: Skin.black,
                      isUnlocked: skinProvider.unlockedSkins.contains(
                        Skin.black,
                      ),
                      isNew: true,
                      onTap: () {
                        if (!skinProvider.unlockedSkins.contains(Skin.black)) {
                          skinProvider.unlockSkin(Skin.black);
                        }
                      },
                    ),
                    SkinItem(
                      skin: Skin.blue,
                      isUnlocked: skinProvider.unlockedSkins.contains(
                        Skin.blue,
                      ),
                      isNew: true,
                      onTap: () {
                        // Buy skin!
                        if (!skinProvider.unlockedSkins.contains(Skin.blue)) {
                          skinProvider.unlockSkin(Skin.blue);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AdProgressBar(
                  adsRequired: adsRequiredForSkin,
                  rewardedAdsWatched: rewardedAdsWatched,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    StoreButton(
                      title: "Remove Ads",
                      price: 9.99,
                      icon: Icons.block,
                      screenWidth: screenWidth,
                      discountText: "Enjoy ad-free gaming!",
                    ),
                  ],
                ),
                const SizedBox(height: 500),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
