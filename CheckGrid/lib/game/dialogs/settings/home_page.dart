import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/dialogs/settings/components/dialog_button.dart';
import 'package:checkgrid/game/dialogs/settings/components/dialog_image.dart';
import 'package:checkgrid/game/dialogs/settings/components/option_tile.dart';
import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:checkgrid/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final Board board;
  final void Function(DialogPage) onNavigate;
  final double dialogWidth;
  final double dialogHeight;

  const HomePage({
    super.key,
    required this.board,
    required this.onNavigate,
    required this.dialogWidth,
    required this.dialogHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: dialogWidth,
            height: dialogHeight,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 41, 107, 161),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                width: 4,
                color: const Color.fromARGB(255, 124, 137, 154),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  const DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text("Settings"),
                  ),
                  const SizedBox(height: 20),
                  OptionTile(
                    title: "Restart game",
                    icon: Icons.restart_alt_rounded,
                    onTap:
                        () => {
                          board.restartGame(context, true),
                          context.read<AudioProvider>().playCloseMenu(),
                          Navigator.pop(context),
                        },
                  ),
                  // OptionTile(
                  //   title: "Difficulty",
                  //   icon: Icons.admin_panel_settings_outlined,
                  //   onTap:
                  //       () => {
                  //         context.read<AudioProvider>().playOpenMenu(),
                  //         onNavigate(DialogPage.difficulty),
                  //       },
                  // ),
                  OptionTile(
                    title: "Skins",
                    icon: FontAwesomeIcons.chessQueen,
                    onTap:
                        () => {
                          context.read<AudioProvider>().playOpenMenu(),
                          onNavigate(DialogPage.skins),
                        },
                  ),
                  OptionTile(
                    title: "Settings",
                    icon: Icons.settings,
                    onTap: () {
                      context.read<AudioProvider>().playOpenMenu();
                      context.push("/settings").then((_) => board.update());
                    },
                  ),
                  const Spacer(),
                  DialogBackButton(
                    text: "Back",
                    onPressed:
                        () => {
                          context.read<AudioProvider>().playCloseMenu(),
                          Navigator.pop(context),
                        },
                  ),
                ],
              ),
            ),
          ),
          DialogImageWidget(
            dialogWidth: dialogWidth,
            currentPage: DialogPage.settings,
          ),
        ],
      ),
    );
  }
}
