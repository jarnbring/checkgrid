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
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              snap: true,
              title: Text("Store", style: TextStyle(fontSize: 22)),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 40,
                          runSpacing: 40,
                          children: [
                            const SizedBox(height: 1),

                            SkinItem(
                              skin: Skin.white,
                              isNew: true,
                              onTap: () {
                                if (!skinProvider.unlockedSkins.contains(
                                  Skin.white,
                                )) {
                                  skinProvider.unlockSkin(Skin.white);
                                }
                              },
                            ),
                            SkinItem(
                              name: "Black",
                              imageName: Skin.black.name,
                              description: 'Unlock all pieces in black',
                              price: 5.0,
                              unlocked: skinProvider.unlockedSkins.contains(
                                Skin.black,
                              ),
                              isNew: true,
                              onTap: () {
                                if (!skinProvider.unlockedSkins.contains(
                                  Skin.black,
                                )) {
                                  skinProvider.unlockSkin(Skin.black);
                                }
                              },
                            ),
                            SkinItem(
                              name: "Blue",
                              imageName: Skin.blue.name,
                              description: 'Unlock all pieces in blue colors',
                              price: 10.0,
                              unlocked: skinProvider.unlockedSkins.contains(
                                Skin.blue,
                              ),
                              unlockText: "Reach 100+ highscore",
                              isNew: true,
                              onTap: () {
                                if (!skinProvider.unlockedSkins.contains(
                                  Skin.blue,
                                )) {
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
                            StandardButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
