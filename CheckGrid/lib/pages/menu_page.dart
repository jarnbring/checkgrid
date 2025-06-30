import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class GameMenu extends StatefulWidget {
  const GameMenu({super.key});

  @override
  State<GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  late String appVersion = 'ALPHA';
  late PageController _pageController;

  final List<MenuItem> items = [
    MenuItem(
      icon: Icons.play_arrow,
      title: 'Play',
      route: '/play',
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 66, 246, 21),
          Color.fromARGB(255, 0, 126, 17),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: _buildShimmerTitle(),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: IconButton(
              onPressed: () => context.go('/settings'),
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 120),
            MenuCard(
              item: items[0],
              onTap: () {
                context.pushNamed(items[0].route);
              },
            ),
            const SizedBox(height: 80),
            _buildSocialIcons(),
            Text(appVersion),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).textTheme.bodyMedium!.color!,
      highlightColor: Colors.grey,
      child: const Text(
        'CheckGrid',
        style: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
    final socialLinks = [
      {'icon': FontAwesomeIcons.tiktok, 'url': 'https://www.tiktok.com/'},
      {'icon': FontAwesomeIcons.instagram, 'url': 'https://www.instagram.com/'},
      {'icon': FontAwesomeIcons.reddit, 'url': 'https://www.reddit.com/'},
      {'icon': FontAwesomeIcons.snapchat, 'url': 'https://www.snapchat.com/'},
      {'icon': FontAwesomeIcons.youtube, 'url': 'https://www.youtube.com/'},
      {'icon': FontAwesomeIcons.xTwitter, 'url': 'https://www.x.com/'},
      {'icon': FontAwesomeIcons.discord, 'url': 'https://www.discord.com/'},
    ];

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
      children:
          chunked.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    row.map((link) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
                          icon: FaIcon(link['icon'] as IconData),
                          iconSize: 25,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () => _launchURL(link['url'] as String),
                        ),
                      );
                    }).toList(),
              ),
            );
          }).toList(),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final Color? color;
  final Gradient? gradient;

  MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    this.color,
    this.gradient,
  });
}

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 250,
          height: 250,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            gradient: item.gradient,
            color: item.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 90,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
