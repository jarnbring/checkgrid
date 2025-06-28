import 'package:checkgrid/animations/border_beam.dart';
import 'package:checkgrid/components/background.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  Widget skinItem({
    required String name,
    required IconData icon,
    required bool unlocked,
    bool isNew = false,
    String? unlockText,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BorderBeam(
            duration: 4,
            colorFrom: const Color.fromARGB(255, 255, 251, 2),
            colorTo: const Color.fromARGB(255, 0, 51, 255),
            staticBorderColor: const Color.fromARGB(255, 0, 0, 251),
            borderRadius: BorderRadius.circular(16),
            borderWidth: 2,
            child: Container(
              width: context.watch<GeneralProvider>().screenWidth(context),
              decoration: BoxDecoration(
                color: unlocked ? Colors.blueAccent : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked ? Colors.amber : Colors.grey,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 48,
                          color: unlocked ? Colors.white : Colors.black26,
                        ),
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
                  ),
                ],
              ),
            ),
          ),
          // NEW-message
          isNew
              ? Positioned(
                top: -40 / 2,
                left: 0,
                width: 80,
                height: 30,
                child: Stack(
                  children: [
                    // Border runt custom form
                    CustomPaint(
                      size: const Size(80, 30),
                      painter: LabelBorderPainter(borderWidth: 4),
                    ),
                    // Själva custom formen
                    ClipPath(
                      clipper: LabelClipper(),
                      child: Container(
                        color: const Color.fromARGB(255, 11, 181, 16),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Stroke (border) på texten
                            Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Antonio',
                                fontWeight: FontWeight.w900,
                                foreground:
                                    Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3
                                      ..color = Colors.black,
                              ),
                            ),
                            // Fylld text
                            const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Antonio',
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Background(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                snap: true,
                title: const Text("Store", style: TextStyle(fontSize: 22)),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 1),
                              skinItem(
                                name: "Classic",
                                icon: Icons.check_box_outline_blank,
                                unlocked: true,
                                isNew: true,
                              ),
                              skinItem(
                                name: "Gold",
                                icon: Icons.star,
                                unlocked: highscore >= 50,
                                unlockText: "Reach 50+ highscore",
                                isNew: true,
                              ),
                              const SizedBox(height: 240),
                              skinItem(
                                name: "Diamond",
                                icon: Icons.diamond,
                                unlocked: highscore >= 100,
                                unlockText: "Reach 100+ highscore",
                                isNew: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}

class LabelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double rectWidth = size.width * 0.7; // 60% rektangel, 40% triangel
    Path path = Path();
    path.moveTo(0, 0); // Start uppe till vänster
    path.lineTo(rectWidth, 0); // Övre rektangelhörn
    path.lineTo(size.width, size.height); // Spets: ner till höger
    path.lineTo(rectWidth, size.height); // Nedre rektangelhörn
    path.lineTo(0, size.height); // Nedre vänster
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class LabelBorderPainter extends CustomPainter {
  final double borderWidth;
  final Color borderColor;

  LabelBorderPainter({
    this.borderWidth = 4,
    this.borderColor = const Color.fromARGB(255, 28, 28, 28),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = LabelClipper().getClip(size);
    final paint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
