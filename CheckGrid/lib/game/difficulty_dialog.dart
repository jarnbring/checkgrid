import 'package:flutter/material.dart';
import 'package:checkgrid/game/difficulty.dart';

void showDifficultyDialog({
  required BuildContext context,
  required Difficulty currentDifficulty,
  required Function(Difficulty) onDifficultySelected,
}) {
  Difficulty selectedDifficulty = currentDifficulty;
  const selectedColor = Color.fromARGB(255, 0, 255, 0);

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
            child: GestureDetector(
              onTap: () {},
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Build container
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        height: 350,
                        width: 275,
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
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                "Choose Difficulty",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Note: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "This will restart your current progress and start a new game.",
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                          selectedDifficulty == difficulty;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDifficulty = difficulty;
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
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: () {
                                  onDifficultySelected(selectedDifficulty);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color.fromARGB(
                                      255,
                                      45,
                                      190,
                                      49,
                                    ),
                                  ),
                                  height: 50,
                                  width: 150,
                                  child: const Center(
                                    child: Text(
                                      "Restart",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Build difficulty icon
                  Positioned(
                    top: -37.5,
                    left: (275 - 75) / 2,
                    child: Image.asset(
                      'assets/images/difficulties/difficulty.png',
                      width: 75,
                      height: 75,
                    ),
                  ),

                  // Build cross icon
                  Positioned(
                    top: 10,
                    left: 232,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(68, 0, 0, 0),
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
