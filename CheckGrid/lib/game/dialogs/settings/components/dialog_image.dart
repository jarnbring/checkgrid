import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:flutter/material.dart';

class DialogImageWidget extends StatelessWidget {
  final int dialogWidth;
  final DialogPage currentPage;
  const DialogImageWidget({
    super.key,
    required this.dialogWidth,
    required this.currentPage,
  });

  final double iconSize = 75;

  String _getImagePathForPage(DialogPage page) {
    switch (page) {
      case DialogPage.settings:
        return 'assets/images/dialog_images/settings_icon.png';
      case DialogPage.difficulty:
        return 'assets/images/dialog_images/difficulty_icon.png';
      case DialogPage.skins:
        return 'assets/images/dialog_images/skins_icon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -iconSize / 2,
      left: (dialogWidth - iconSize) / 2,
      child: Image.asset(
        _getImagePathForPage(currentPage),
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
