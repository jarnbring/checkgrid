import 'package:checkgrid/new_game/game_ui.dart';
import 'package:checkgrid/pages/statistics_page.dart';
import 'package:checkgrid/pages/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:checkgrid/pages/store_page.dart';
import 'package:checkgrid/pages/feedback_page.dart';
import 'package:checkgrid/pages/menu_page.dart';
import 'package:checkgrid/pages/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(
      name: '/splash',
      path: '/splash',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      name: '/menu',
      path: '/menu',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MenuPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      name: '/play',
      path: '/play',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const Game(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      name: '/store',
      path: '/store',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const StorePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      name: '/settings',
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      name: '/statistics',
      path: '/statistics',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const StatisticsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      name: '/feedback',
      path: '/feedback',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FeedbackPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
  ],
);
