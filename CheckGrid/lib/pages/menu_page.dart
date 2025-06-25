import 'package:checkgrid/new_game/utilities/background.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:checkgrid/components/pressable_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late String appVersion = '';
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    // Delayed animation trigger for fading in content
    Future.delayed(const Duration(milliseconds: 0), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  // Loads the app version
  void _loadVersion() {
    appVersion = '0.0.1'; // Default version
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
                  iconSize: 25,
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F), // Samma som GameOverPage!
      body: Background(
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedOpacity(
              opacity: _showContent ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  _buildCheckGridText(),
                  const SizedBox(height: 60),
                  PressableButton(title: "Play", route: "/play"),
                  const SizedBox(height: 40),
                  PressableButton(title: "Store", route: "/store"),
                  const SizedBox(height: 40),
                  PressableButton(title: "Settings", route: "/settings"),
                  const SizedBox(height: 40),
                  PressableButton(title: "Statistics", route: "/statistics"),
                  const SizedBox(height: 40),
                  PressableButton(title: "Feedback", route: "/feedback"),
                  const SizedBox(height: 40),
                  // Social icons row
                  _buildSocials(),
                  SizedBox(height: 40),
                  // App version text
                  Text(appVersion),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
