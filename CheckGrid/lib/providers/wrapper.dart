import 'package:checkgrid/ads/banner_ad.dart';
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

class _HomeWrapperState extends State<HomeWrapper>
    with TickerProviderStateMixin {
  final PageController _controller = PageController(initialPage: 1);
  int _currentIndex = 1;
  double _currentPageValue = 1.0;
  bool _isAnimating = false;
  double _dragStartX = 0;
  double _dragStartPageValue = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Lägg till listener för realtidssynkronisering
    _controller.addListener(_pageListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_pageListener);
    _controller.dispose();
    super.dispose();
  }

  // Ny listener för realtidssynkronisering
  void _pageListener() {
    if (_controller.hasClients && _controller.page != null) {
      setState(() {
        _currentPageValue = _controller.page!;
      });
      final currentPage = _controller.page!.round();
      if (currentPage != _currentIndex && !_isAnimating) {
        setState(() {
          _currentIndex = currentPage;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    _isAnimating = true;

    // Animera currentPageValue manuellt för smooth transition
    final targetValue = index.toDouble();
    final duration = const Duration(milliseconds: 300);

    // Skapa egen animation för currentPageValue
    final animationController = AnimationController(
      duration: duration,
      vsync: this,
    );

    final animation = Tween<double>(
      begin: _currentPageValue,
      end: targetValue,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animation.addListener(() {
      setState(() {
        _currentPageValue = animation.value;
      });
    });

    animationController.forward();

    _controller
        .animateToPage(index, duration: duration, curve: Curves.easeInOut)
        .then((_) {
          setState(() {
            _currentIndex = index;
            _isAnimating = false;
          });
          animationController.dispose();
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
                    // Känslig på vänster sida
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
                    // Känslig på höger sida
                    _swipeLeft();
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 62,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (details) {
                _isDragging = true;
                _dragStartX = details.globalPosition.dx;
                _dragStartPageValue = _currentPageValue;
              },
              onHorizontalDragUpdate: (details) {
                if (_isDragging) {
                  final dragDistance = details.globalPosition.dx - _dragStartX;
                  final screenWidth = MediaQuery.of(context).size.width;

                  // Öka känsligheten - dela med mindre värde för snabbare rörelse
                  final pageValueChange = dragDistance / (screenWidth / 3);
                  final newPageValue = (_dragStartPageValue + pageValueChange)
                      .clamp(0.0, 2.0);

                  setState(() {
                    _currentPageValue = newPageValue;
                  });
                }
              },
              onHorizontalDragEnd: (details) {
                if (_isDragging) {
                  _isDragging = false;

                  // Snappa alltid till närmaste ikon baserat på position
                  final targetIndex = _currentPageValue.round().clamp(0, 2);

                  // Uppdatera _currentIndex direkt för att undvika animation från fel position
                  setState(() {
                    _currentIndex = targetIndex;
                  });

                  // Animera bara currentPageValue, inte hela sidan
                  final animationController = AnimationController(
                    duration: const Duration(milliseconds: 200),
                    vsync: this,
                  );

                  final animation = Tween<double>(
                    begin: _currentPageValue,
                    end: targetIndex.toDouble(),
                  ).animate(
                    CurvedAnimation(
                      parent: animationController,
                      curve: Curves.easeOut,
                    ),
                  );

                  animation.addListener(() {
                    setState(() {
                      _currentPageValue = animation.value;
                    });
                  });

                  animationController.forward().then((_) {
                    // Byt sida när animationen är klar
                    _controller.jumpToPage(targetIndex);
                    animationController.dispose();
                  });
                }
              },
              child: CustomBottomNav(
                currentIndex: _currentIndex,
                currentPageValue: _currentPageValue,
                onItemTap: _onItemTapped,
              ),
            ),
          ),
          const SizedBox.shrink(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const BannerAdWidget(),
          ),
        ],
      ),
    );
  }
}
