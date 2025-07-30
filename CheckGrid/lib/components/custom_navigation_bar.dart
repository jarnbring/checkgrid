import 'package:checkgrid/components/glass_box.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GlassBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Indicator
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
                          color: CupertinoColors.systemBlue.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemBlue.withOpacity(
                                0.3,
                              ),
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
                        _navItem(1, FontAwesomeIcons.solidChessKnight, context),
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
    );
  }

  double _getIndicatorPosition(double pageValue, double totalWidth) {
    final itemWidth = 60.0;
    final totalItemsWidth = 3 * itemWidth;
    final remainingSpace = totalWidth - totalItemsWidth;
    final spaceUnit = remainingSpace / 6;

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
      behavior: HitTestBehavior.opaque, // Gör hela området klickbart
      child: Padding(
        padding: const EdgeInsets.all(18), // Osynlig klickbar padding
        child: AnimatedScale(
          scale: isSelected ? 1.3 : 0.8,
          duration: const Duration(milliseconds: 150),
          child: Icon(
            icon,
            color:
                isSelected
                    ? CupertinoColors.white
                    : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
