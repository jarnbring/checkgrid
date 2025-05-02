import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamename/banner_ad.dart';
import 'package:gamename/pages/feedback_page.dart';
import 'package:gamename/pages/game_page.dart';
import 'package:gamename/pages/store_page.dart';
import 'package:gamename/providers/general_provider.dart';
import 'package:gamename/settings/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  double lifespan;
  Color color;
  final double _initialLifespan;

  static const double _gravity = 0.1; // Gravitationseffekt

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifespan,
    required this.color,
  }) : _initialLifespan = lifespan;

  void update() {
    position += velocity;
    velocity = Offset(velocity.dx, velocity.dy + _gravity);
    lifespan -= 1 / 60;

    final sizeFactor = 1.0 + (sin(lifespan * pi * 2) * 0.1);
    size = (size * sizeFactor).clamp(0.5, 2.0);

    color = color.withOpacity((lifespan / _initialLifespan).clamp(0.0, 1.0));
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Size textSize;
  final Offset textPosition;

  ParticlePainter({
    required this.particles,
    required this.textSize,
    required this.textPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      if (particle.lifespan <= 0) continue;

      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
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
          elevation: 5,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
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
              style: const TextStyle(color: Colors.white, fontSize: 18),
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
      {'icon': FontAwesomeIcons.xTwitter, 'url': 'https://www.x.com/'},
      {'icon': FontAwesomeIcons.discord, 'url': 'https://www.discord.com/'},
    ];

    final firstRowLinks = socialLinks.take(4).toList();
    final secondRowLinks = socialLinks.skip(4).toList();

    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeIn,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const SizedBox(height: 20),
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
      debugPrint('Could not launch $url');
    }
  }

  Widget _buildGameNameText() {
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 3000),
      curve: Curves.easeIn,
      child: Shimmer.fromColors(
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
      ),
    );
  }

  Widget _buildNormalMenu(double screenHeight, double scaleFactorHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight / scaleFactorHeight * 1.75),
        _buildGameNameText(),
        SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
        menuButton("Play", const GamePage()),
        SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
        menuButton("Settings", const SettingsPage()),
        SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
        menuButton("Store", const StorePage()),
        SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
        menuButton("Feedback", const FeedbackPage()),
        SizedBox(height: screenHeight / scaleFactorHeight * 0.5),
        socials(),
        SizedBox(height: screenHeight / (scaleFactorHeight * 2)),
        AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
          child: Text(appVersion),
        ),
        SizedBox(height: screenHeight / (scaleFactorHeight * 0.25)),
      ],
    );
  }

  Widget _buildTabletLandscapeMenu(
    double screenHeight,
    double scaleFactorHeight,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight / scaleFactorHeight),
        _buildGameNameText(),
        SizedBox(height: screenHeight / scaleFactorHeight),
        Wrap(
          spacing: screenHeight / scaleFactorHeight,
          runSpacing: screenHeight / scaleFactorHeight,
          children: [
            menuButton("Play", const GamePage()),
            menuButton("Settings", const SettingsPage()),
          ],
        ),
        SizedBox(height: screenHeight / scaleFactorHeight),
        Wrap(
          spacing: screenHeight / scaleFactorHeight,
          runSpacing: screenHeight / scaleFactorHeight,
          children: [
            menuButton("Store", const StorePage()),
            menuButton("Feedback", const FeedbackPage()),
          ],
        ),
        SizedBox(height: screenHeight / scaleFactorHeight),
        socials(),
        SizedBox(height: screenHeight / (scaleFactorHeight * 2)),
        AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
          child: Text(appVersion),
        ),
        SizedBox(height: screenHeight / (scaleFactorHeight * 2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();
    double bannerAdHeight = generalProvider.getBannerAdHeight();
    double screenHeight =
        generalProvider.getScreenHeight(context) - bannerAdHeight;
    bool isTablet = generalProvider.isTablet(context);
    bool isLandscape = generalProvider.getLandscapeMode(context);
    bool isTabletAndLandscape = isTablet && isLandscape;
    double scaleFactorHeight = 13.3;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child:
              isTabletAndLandscape
                  ? _buildTabletLandscapeMenu(screenHeight, scaleFactorHeight)
                  : _buildNormalMenu(screenHeight, scaleFactorHeight),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
