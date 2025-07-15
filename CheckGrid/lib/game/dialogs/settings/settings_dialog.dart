import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/dialogs/settings/difficulty_page.dart';
import 'package:checkgrid/game/dialogs/settings/home_page.dart';
import 'package:checkgrid/game/dialogs/settings/skins_page.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DialogPage { settings, difficulty, skins }

void showSettingsDialog({required Board board, required BuildContext context}) {
  final audioProvider = context.read<AudioProvider>();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, _, _) => _SettingsDialog(board: board),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(curved),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  ).then((result) {
    if (result == null) {
      audioProvider.playCloseMenu();
    }
  });
}

class _SettingsDialog extends StatefulWidget {
  final Board board;

  const _SettingsDialog({required this.board});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  DialogPage currentPage = DialogPage.settings;
  final int dialogWidth = 300;
  final int dialogHeight = 500;

  @override
  Widget build(BuildContext context) {
    switch (currentPage) {
      case DialogPage.settings:
        return HomePage(
          board: widget.board,
          onNavigate: (page) => setState(() => currentPage = page),
          dialogWidth: dialogWidth,
          dialogHeight: dialogHeight,
        );
      case DialogPage.difficulty:
        return DifficultyPage(
          board: widget.board,
          onBack: () => setState(() => currentPage = DialogPage.settings),
          dialogWidth: dialogWidth,
          dialogHeight: dialogHeight,
        );
      case DialogPage.skins:
        return SkinsPage(
          board: widget.board,
          onBack: () => setState(() => currentPage = DialogPage.settings),
          dialogWidth: dialogWidth,
          dialogHeight: dialogHeight,
        );
    }
  }
}
