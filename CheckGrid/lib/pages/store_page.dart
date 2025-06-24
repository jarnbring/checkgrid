import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // Dummy-data för exempel
  int highscore = 100;
  int rewardedAdsWatched = 21; // Byt till din riktiga provider/state
  final int adsRequiredForSkin = 20;

  @override
  void initState() {
    super.initState();
  }

  Widget purchaseableItem({
    required String title,
    required double price,
    required IconData icon,
    required double screenWidth,
    bool isHighlighted = false,
    String? discountText,
  }) {
    return Container(
      width: screenWidth * 0.75,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(64, 0, 0, 0),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors:
                  isHighlighted
                      ? [Colors.orange, Colors.red]
                      : [Colors.lightGreen, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "£$price",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (discountText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    discountText,
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget skinItem({
    required String name,
    required IconData icon,
    required bool unlocked,
    String? unlockText,
  }) {
    return Container(
      width: 110,
      height: 110,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: unlocked ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? Colors.amber : Colors.grey,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: unlocked ? Colors.white : Colors.black26),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!unlocked && unlockText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                unlockText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 9, // Mindre text
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2, // Tillåt radbrytning
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget adsProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Watch ads to unlock special skin:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: rewardedAdsWatched / adsRequiredForSkin,
          minHeight: 12,
          backgroundColor: Colors.grey.shade300,
          color: Colors.orange,
        ),
        const SizedBox(height: 4),
        Text(
          "$rewardedAdsWatched / $adsRequiredForSkin ads watched",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Store", style: TextStyle(fontSize: 22)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/menu');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Skins beroende på highscore
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        skinItem(
                          name: "Classic",
                          icon: Icons.check_box_outline_blank,
                          unlocked: true,
                        ),
                        skinItem(
                          name: "Gold",
                          icon: Icons.star,
                          unlocked: highscore >= 50,
                          unlockText: "Reach 50+ highscore",
                        ),
                        skinItem(
                          name: "Diamond",
                          icon: Icons.diamond,
                          unlocked: highscore >= 100,
                          unlockText: "Reach 100+ highscore",
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progressbar för att låsa upp skin via ads
                    adsProgressBar(),

                    const SizedBox(height: 24),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        purchaseableItem(
                          title: "Remove Ads",
                          price: 9.99,
                          icon: Icons.block,
                          screenWidth: screenWidth,
                          discountText: "Enjoy ad-free gaming!",
                        ),
                        // Lägg till fler köpbara items här
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      //bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
