import 'package:CheckGrid/pages/statistics_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:CheckGrid/pages/game_page.dart';
import 'package:CheckGrid/pages/store_page.dart';
import 'package:CheckGrid/pages/feedback_page.dart';
import 'package:CheckGrid/pages/menu_page.dart';
import 'package:CheckGrid/settings/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: "/menu",
  routes: [
    GoRoute(
      name: '/menu',
      path: '/menu',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const MenuPage()),
    ),
    GoRoute(
      name: '/play',
      path: '/play',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const GamePage()),
    ),
    GoRoute(
      name: '/store',
      path: '/store',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const StorePage()),
    ),
    GoRoute(
      name: '/settings',
      path: '/settings',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const SettingsPage()),
    ),
    GoRoute(
      name: '/statistics',
      path: '/statistics',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const StatsiticsPage()),
    ),
    GoRoute(
      name: '/feedback',
      path: '/feedback',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: const FeedbackPage()),
    ),
  ],
);
