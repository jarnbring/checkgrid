import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamename/pages/game_page.dart';
import 'package:gamename/settings/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _showContent = false;
  double iconSize = 25;
  String appVersion = "Beta 1.0.0";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _showContent = true;
      });
    });
  }

  Widget menuButton(String title, Widget routePage) {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => routePage),
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 20,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            width: 200,
            height: 60,
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget socials() {
    final socialLinks = [
      {'icon': FontAwesomeIcons.tiktok, 'url': 'https://www.tiktok.com/'},
      {'icon': FontAwesomeIcons.instagram, 'url': 'https://www.instagram.com/'},
      {'icon': FontAwesomeIcons.reddit, 'url': 'https://www.reddit.com/'},
      {'icon': FontAwesomeIcons.snapchat, 'url': 'https://www.snapchat.com/'},
      {'icon': FontAwesomeIcons.youtube, 'url': 'https://www.youtube.com/'},
      {'icon': FontAwesomeIcons.x, 'url': 'https://www.x.com/'},
      {'icon': FontAwesomeIcons.discord, 'url': 'https://www.discord.com/'},
    ];

    // Dela upp socialLinks i två lika delar för två rader
    final firstRowLinks = socialLinks.take(4).toList();
    final secondRowLinks = socialLinks.skip(4).toList();

    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Första raden med ikoner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(firstRowLinks.length, (index) {
              final link = firstRowLinks[index];
              return AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: Duration(milliseconds: 800 + (index * 200)),
                curve: Curves.easeIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                    icon: FaIcon(link['icon'] as IconData),
                    iconSize: iconSize,
                    onPressed: () => _launchURL(link['url'] as String),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20), // Lite mellanrum mellan raderna
          // Andra raden med ikoner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(secondRowLinks.length, (index) {
              final link = secondRowLinks[index];
              return AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: Duration(milliseconds: 800 + (index * 200)),
                curve: Curves.easeIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                    icon: FaIcon(link['icon'] as IconData),
                    iconSize: iconSize,
                    onPressed: () => _launchURL(link['url'] as String),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            AnimatedOpacity(
              opacity: _showContent ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              child: Text('CheckGrid', style: TextStyle(fontSize: 35)),
            ),
            const SizedBox(height: 75),
            menuButton("Play", GamePage()),
            const SizedBox(height: 50),
            menuButton("Settings", SettingsPage()),
            const SizedBox(height: 50),
            menuButton("Feedback", GamePage()),
            const Spacer(),
            const SizedBox(height: 100),
            socials(),
            const SizedBox(height: 50),
            AnimatedOpacity(
              opacity: _showContent ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              child: Text(appVersion, style: TextStyle()),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
