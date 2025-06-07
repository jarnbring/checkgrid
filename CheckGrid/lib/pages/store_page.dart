import 'package:flutter/material.dart';
import 'package:CheckGrid/providers/general_provider.dart';
import 'package:provider/provider.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _showContent = true;
      });
    });
  }

  Widget purchaseableItem({
    required String title,
    required double price,
    required IconData icon,
    required double screenWidth,
    required bool isTablet,
    bool isHighlighted = false,
    String? discountText,
  }) {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: Container(
        width: screenWidth * 0.75,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            print("Purchased $title for £$price");
            // TODO: Implementera köplogik (t.ex. in_app_purchase)
          },
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
                          Icon(
                            icon,
                            color: Colors.white,
                            size: isTablet ? 28 : 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "£$price",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
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
                        fontSize: isTablet ? 14 : 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    final screenWidth = generalProvider.getScreenWidth(context);
    final screenHeight = generalProvider.getScreenHeight(context);
    final bannerAdHeight = generalProvider.getBannerAdHeight();
    final isTablet = generalProvider.isTablet(context);
    final adjustedScreenHeight = screenHeight - bannerAdHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text("Store", style: TextStyle(fontSize: isTablet ? 26 : 22)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 1000 : 600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: adjustedScreenHeight * 0.03,
                ),
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _showContent ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1200),
                      child: Text(
                        "Unlock Amazing Features!",
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: adjustedScreenHeight * 0.03),
                    Wrap(
                      spacing: screenWidth * 0.05,
                      runSpacing: adjustedScreenHeight * 0.02,
                      alignment: WrapAlignment.center,
                      children: [
                        purchaseableItem(
                          title: "Remove Ads",
                          price: 9.99,
                          icon: Icons.block,
                          screenWidth: screenWidth,
                          isTablet: isTablet,
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
      ),
      //bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
