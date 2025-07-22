import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialsPage extends StatelessWidget {
  const SocialsPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth - 80) / 4; // 3 per rad, minus padding

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Socials',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  "Thank you for playing!\nStay connected with us:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 20,
                  runSpacing: 20,
                  children: _buildSocialButtons(iconSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSocialButtons(double size) {
    final socialLinks = [
      {'icon': FontAwesomeIcons.tiktok, 'url': 'https://www.tiktok.com/'},
      {'icon': FontAwesomeIcons.instagram, 'url': 'https://www.instagram.com/'},
      {'icon': FontAwesomeIcons.reddit, 'url': 'https://www.reddit.com/'},
      {'icon': FontAwesomeIcons.snapchat, 'url': 'https://www.snapchat.com/'},
      {'icon': FontAwesomeIcons.youtube, 'url': 'https://www.youtube.com/'},
      {'icon': FontAwesomeIcons.xTwitter, 'url': 'https://www.x.com/'},
      {'icon': FontAwesomeIcons.discord, 'url': 'https://www.discord.com/'},
      // Add for your website
    ];

    return socialLinks.map((link) {
      return GestureDetector(
        onTap: () => _launchURL(link['url'] as String),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5AC8FA), Color(0xFF007AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(
              link['icon'] as IconData,
              size: size * 0.4,
              color: Colors.white,
            ),
          ),
        ),
      );
    }).toList();
  }
}
