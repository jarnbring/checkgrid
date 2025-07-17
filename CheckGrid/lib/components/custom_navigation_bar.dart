import 'dart:ui';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final double currentPageValue;
  final Function(int) onItemTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.currentPageValue,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Glidande blå bakgrund med realtidsanimation
                        Positioned(
                          left: _getIndicatorPosition(
                            currentPageValue,
                            constraints.maxWidth,
                          ),
                          top: 0,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Nav items
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _navItem(0, FontAwesomeIcons.chartColumn, context),
                            _navItem(
                              1,
                              FontAwesomeIcons.solidChessKnight,
                              context,
                            ),
                            _navItem(2, FontAwesomeIcons.tags, context),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Beräkna position för den glidande indikatorn baserat på currentPageValue
  double _getIndicatorPosition(double pageValue, double totalWidth) {
    final itemWidth = 60.0;
    final totalItemsWidth = 3 * itemWidth; // 180
    final remainingSpace = totalWidth - totalItemsWidth;
    final spaceUnit = remainingSpace / 6;

    // Beräkna position baserat på pageValue (kan vara decimal)
    // pageValue 0.0 = första positionen
    // pageValue 1.0 = andra positionen
    // pageValue 2.0 = tredje positionen

    final position0 = spaceUnit;
    final position1 = spaceUnit + itemWidth + (2 * spaceUnit);
    final position2 = spaceUnit + (2 * itemWidth) + (4 * spaceUnit);

    if (pageValue <= 0.0) {
      return position0;
    } else if (pageValue >= 2.0) {
      return position2;
    } else if (pageValue <= 1.0) {
      // Interpolera mellan position 0 och 1
      return position0 + (position1 - position0) * pageValue;
    } else {
      // Interpolera mellan position 1 och 2
      return position1 + (position2 - position1) * (pageValue - 1.0);
    }
  }

  Widget _navItem(int index, IconData icon, BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        context.read<SettingsProvider>().doVibration(2);
        onItemTap(index);
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              size: isSelected ? 28 : 24,
              color:
                  isSelected
                      ? Colors.blueAccent
                      : Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}
