import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/dialogs/settings/components/dialog_button.dart';
import 'package:checkgrid/game/dialogs/settings/components/dialog_image.dart';
import 'package:checkgrid/game/dialogs/settings/components/small_button.dart';
import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:checkgrid/game/utilities/difficulty.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DifficultyPage extends StatefulWidget {
  final Board board;
  final VoidCallback onBack;
  final double dialogWidth;
  final double dialogHeight;

  const DifficultyPage({
    super.key,
    required this.board,
    required this.onBack,
    required this.dialogWidth,
    required this.dialogHeight,
  });

  @override
  State<DifficultyPage> createState() => _DifficultyPageState();
}

class _DifficultyPageState extends State<DifficultyPage> {
  late Difficulty selectedDifficulty;
  final selectedColor = const Color.fromARGB(255, 0, 255, 0);

  @override
  void initState() {
    super.initState();
    selectedDifficulty = widget.board.difficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.dialogWidth,
            height: widget.dialogHeight,
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
                  const SizedBox(height: 20),
                  DefaultTextStyle(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    child: Text("Choose Difficulty"),
                  ),
                  const SizedBox(height: 20),
                  DefaultTextStyle(
                    style: TextStyle(),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Note: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          TextSpan(
                            text:
                                "This will reset your current progress and start a new game.",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        Difficulty.values.map((difficulty) {
                          String asset;
                          switch (difficulty) {
                            case Difficulty.easy:
                              asset =
                                  'assets/images/difficulties/easy_icon.png';
                              break;
                            case Difficulty.medium:
                              asset =
                                  'assets/images/difficulties/medium_icon.png';
                              break;
                            case Difficulty.hard:
                              asset =
                                  'assets/images/difficulties/hard_icon.png';
                              break;
                          }
                          final isSelected = selectedDifficulty == difficulty;
                          return GestureDetector(
                            onTap: () {
                              context.read<SettingsProvider>().doVibration(1);
                              setState(() {
                                selectedDifficulty = difficulty;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Image.asset(
                                asset,
                                height: 67,
                                width: 67,
                                color:
                                    isSelected ? selectedColor : Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const Spacer(),
                  DialogBackButton(
                    text: "Restart",
                    onPressed: () {
                      widget.board.difficulty = selectedDifficulty;
                      widget.board.restartGame(context, true);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          DialogImageWidget(
            dialogWidth: widget.dialogWidth,
            currentPage: DialogPage.difficulty,
          ),
          SmallUpperButton(
            isX: false,
            onPressed: () {
              context.read<SettingsProvider>().doVibration(1);
              widget.onBack();
            },
          ),
        ],
      ),
    );
  }
}
