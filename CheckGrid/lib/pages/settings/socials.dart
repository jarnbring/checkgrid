import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum SocialLink {
  tiktok(FontAwesomeIcons.tiktok, 'https://www.tiktok.com/', Colors.black),
  instagram(
    FontAwesomeIcons.instagram,
    'https://www.instagram.com/',
    Colors.pink,
  ),
  reddit(FontAwesomeIcons.reddit, 'https://www.reddit.com/', Colors.deepOrange),
  snapchat(
    FontAwesomeIcons.snapchat,
    'https://www.snapchat.com/',
    Color.fromARGB(255, 199, 180, 13),
  ),
  youtube(FontAwesomeIcons.youtube, 'https://www.youtube.com/', Colors.red),
  x(FontAwesomeIcons.xTwitter, 'https://www.x.com/', Colors.black),
  discord(
    FontAwesomeIcons.discord,
    'https://www.discord.com/',
    Color.fromARGB(255, 39, 104, 194),
  );

  final IconData icon;
  final String url;
  final Color color;

  const SocialLink(this.icon, this.url, this.color);
}

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
    final iconSize = 260 / 4;

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
                  alignment: WrapAlignment.center,
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
    return SocialLink.values.map((social) {
      return GestureDetector(
        onTap: () => _launchURL(social.url),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: social.color,
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
            child: FaIcon(social.icon, size: size * 0.4, color: Colors.white),
          ),
        ),
      );
    }).toList();
  }
}
