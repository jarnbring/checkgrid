import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 54, 78, 100),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, FontAwesomeIcons.chartColumn),
            _navItem(1, FontAwesomeIcons.solidChessKnight),
            _navItem(2, FontAwesomeIcons.store),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onItemTap(index),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: Icon(
            icon,
            size: isSelected ? 36 : 24,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
