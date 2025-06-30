import 'package:flutter/material.dart';
import 'package:checkgrid/game/utilities/difficulty.dart';
import 'package:go_router/go_router.dart';

enum DialogPage {
  settings,
  difficulty,
} // Animation between settings and difficulty? fade?

/// Shows a settingsmenu. Intended for ingame use

void showSettingsDialog({
  required BuildContext context,
  required Difficulty currentDifficulty,
  required Function(Difficulty) onDifficultySelected,
  required VoidCallback onRestart,
  required VoidCallback onSettingsPage,
}) {
  Difficulty selectedDifficulty = currentDifficulty;
  const selectedColor = Color.fromARGB(255, 0, 255, 0);

  DialogPage currentPage = DialogPage.settings;

  final double dialogHeight = 400;
  final double dialogWidth = 300;
  final double iconSize = 75;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return GestureDetector(
                  onTap: () {},
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: dialogHeight,
                        width: dialogWidth,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 41, 107, 161),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 4,
                            color: const Color.fromARGB(255, 124, 137, 154),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child:
                              currentPage == DialogPage.settings
                                  ? Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Settings",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _OptionTile(
                                        title: "Restart game",
                                        icon: Icons.restart_alt_rounded,
                                        onTap: onRestart,
                                      ),
                                      _OptionTile(
                                        title: "Difficulty",
                                        icon:
                                            Icons.admin_panel_settings_outlined,
                                        onTap: () {
                                          setState(() {
                                            currentPage = DialogPage.difficulty;
                                          });
                                        },
                                      ),
                                      _OptionTile(
                                        title: "Settings page",
                                        icon: Icons.settings,
                                        onTap: onSettingsPage,
                                      ),
                                      const Spacer(),
                                      _BackButtonWidget(
                                        text: "Back",
                                        onPressed: () {
                                          if (context.canPop()) {
                                            context.pop();
                                          } else {
                                            context.go('/home');
                                          }
                                        },
                                      ),
                                    ],
                                  )
                                  : Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Choose Difficulty",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text.rich(
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
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        spacing: 20,
                                        children:
                                            Difficulty.values.map((difficulty) {
                                              String assetName;
                                              switch (difficulty) {
                                                case Difficulty.easy:
                                                  assetName =
                                                      'assets/images/difficulties/easy_icon.png';
                                                  break;
                                                case Difficulty.medium:
                                                  assetName =
                                                      'assets/images/difficulties/medium_icon.png';
                                                  break;
                                                case Difficulty.hard:
                                                  assetName =
                                                      'assets/images/difficulties/hard_icon.png';
                                                  break;
                                              }
                                              final isSelected =
                                                  selectedDifficulty ==
                                                  difficulty;
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedDifficulty =
                                                        difficulty;
                                                  });
                                                },
                                                child: Image.asset(
                                                  assetName,
                                                  height: 67,
                                                  width: 67,
                                                  color:
                                                      isSelected
                                                          ? selectedColor
                                                          : Colors.white,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                      const Spacer(),
                                      _BackButtonWidget(
                                        text: "Restart",
                                        onPressed: () {
                                          onDifficultySelected(
                                            selectedDifficulty,
                                          );
                                          onRestart();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      if (currentPage == DialogPage.difficulty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = DialogPage.settings;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(68, 0, 0, 0),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: -iconSize / 2,
                        left: (dialogWidth - iconSize) / 2,
                        child: Image.asset(
                          currentPage == DialogPage.settings
                              ? 'assets/images/settings_icon.png'
                              : 'assets/images/difficulties/difficulty.png',
                          width: iconSize,
                          height: iconSize,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(68, 0, 0, 0),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
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
  );
}

class _OptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 32, 135, 219),
      ),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon, color: Colors.white),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).iconTheme.color?.withAlpha(255),
        ),
        onTap: () {
          onTap();
          if (title != "Difficulty") {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

class _BackButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _BackButtonWidget({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 45, 190, 49),
        ),
        height: 50,
        width: 150,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
