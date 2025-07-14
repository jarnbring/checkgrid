import 'package:checkgrid/components/background.dart';
import 'package:checkgrid/components/custom_navigation_bar.dart';
import 'package:checkgrid/game/game_ui.dart';
import 'package:checkgrid/pages/statistics_page.dart';
import 'package:checkgrid/pages/store/store_page.dart';
import 'package:flutter/material.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  final PageController _controller = PageController(initialPage: 1);
  int _currentIndex = 1;
  bool _isAnimating = false;

  void _onItemTapped(int index) {
    _isAnimating = true;
    _controller
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          setState(() {
            _currentIndex = index;
            _isAnimating = false;
          });
        });
  }

  void _swipeLeft() {
    if (_currentIndex < 2) {
      _onItemTapped(_currentIndex + 1);
    }
  }

  void _swipeRight() {
    if (_currentIndex > 0) {
      _onItemTapped(_currentIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            onPageChanged: (index) {
              if (!_isAnimating) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            children: const [StatisticsPage(), Game(), StorePage()],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 40,
              height: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 0) {
                    _swipeRight();
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 40,
              height: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < 0) {
                    _swipeLeft();
                  }
                },
              ),
            ),
          ),

          CustomBottomNav(
            currentIndex: _currentIndex,
            onItemTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
