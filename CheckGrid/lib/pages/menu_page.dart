import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:CheckGrid/ads/banner_ad.dart';
import 'package:CheckGrid/components/pressable_button.dart';
import 'package:CheckGrid/providers/general_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _showContent = false;
  final double iconSize = 25;
  final String appVersion = "Beta 1.0.0";

  @override
  void initState() {
    super.initState();
    // Delayed animation trigger for fading in content
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  Widget _buildSocials() {
    final socialLinks = [
      {'icon': FontAwesomeIcons.tiktok, 'url': 'https://www.tiktok.com/'},
      {'icon': FontAwesomeIcons.instagram, 'url': 'https://www.instagram.com/'},
      {'icon': FontAwesomeIcons.reddit, 'url': 'https://www.reddit.com/'},
      {'icon': FontAwesomeIcons.snapchat, 'url': 'https://www.snapchat.com/'},
      {'icon': FontAwesomeIcons.youtube, 'url': 'https://www.youtube.com/'},
      {'icon': FontAwesomeIcons.xTwitter, 'url': 'https://www.x.com/'},
      {'icon': FontAwesomeIcons.discord, 'url': 'https://www.discord.com/'},
    ];

    // Split the list into chunks of 4 items each
    List<List<Map<String, dynamic>>> chunked = [];
    for (var i = 0; i < socialLinks.length; i += 4) {
      chunked.add(
        socialLinks.sublist(
          i,
          i + 4 > socialLinks.length ? socialLinks.length : i + 4,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(chunked.length, (rowIndex) {
        final row = chunked[rowIndex];
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex != chunked.length - 1 ? 20.0 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(row.length, (i) {
              final link = row[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: FaIcon(link['icon'] as IconData),
                  iconSize: iconSize,
                  onPressed: () => _launchURL(link['url'] as String),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // Opens URL using the device's external browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  // Displays animated game name with shimmer effect
  Widget _buildCheckGridText() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).textTheme.bodyMedium!.color!,
      highlightColor: Colors.grey,
      child: const Text(
        'CheckGrid',
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    double bannerAdHeight = generalProvider.getBannerAdHeight();
    double screenHeight =
        generalProvider.getScreenHeight(context) - bannerAdHeight;
    double scaleFactorHeight = 13.3;

    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 3000),
      curve: Curves.easeIn,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top spacing
                SizedBox(height: screenHeight / scaleFactorHeight * 1.75),

                // Game title with shimmer effect
                _buildCheckGridText(),
                SizedBox(height: screenHeight / scaleFactorHeight * 0.5),

                // Main menu buttons using PressableButton
                const SizedBox(height: 20),
                PressableButton(title: "Play", route: "/play"),
                SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
                PressableButton(title: "Store", route: "/store"),
                SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
                PressableButton(title: "Settings", route: "/settings"),
                SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
                PressableButton(title: "Feedback", route: "/feedback"),
                SizedBox(height: screenHeight / scaleFactorHeight * 0.5),

                // Social icons row
                _buildSocials(),
                SizedBox(height: screenHeight / (scaleFactorHeight * 2)),

                // App version text
                Text(appVersion),

                // Extra spacing if needed
                // SizedBox(height: screenHeight / (scaleFactorHeight)),
              ],
            ),
          ),
        ),

        // Bottom banner ad
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }
}
