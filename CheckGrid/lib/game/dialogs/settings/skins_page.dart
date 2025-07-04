import 'package:checkgrid/game/dialogs/settings/components/dialog_image.dart';
import 'package:checkgrid/game/dialogs/settings/components/small_button.dart';
import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/game/board.dart';

class SkinsPage extends StatefulWidget {
  final Board board;
  final VoidCallback onBack;
  final int dialogWidth;
  final int dialogHeight;

  const SkinsPage({
    super.key,
    required this.board,
    required this.onBack,
    required this.dialogWidth,
    required this.dialogHeight,
  });

  @override
  State<SkinsPage> createState() => _SkinsPageState();
}

class _SkinsPageState extends State<SkinsPage> {
  // ----- Add new skins here! -----
  final List<String> skins = [
    'white',
    'black',
    'white',
    'black',
    'white',
    'black',
    'white',
    'black',
    'white',
    'black',
  ];

  // Retrieve from GeneralProvider
  int selectedIndex = 0; // Already selected skin

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.dialogWidth.toDouble(),
            height: widget.dialogHeight.toDouble(),
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
                  const DefaultTextStyle(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    child: Text("Select Skin"),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                      itemCount: skins.length,
                      itemBuilder: (context, index) {
                        final skinName = skins[index];
                        final isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isSelected ? Colors.lightBlue : Colors.grey,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              // Image
                              child: Image.asset(
                                "assets/images/pieces/$skinName/${skinName}_knight.png",
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          DialogImageWidget(
            dialogWidth: widget.dialogWidth,
            currentPage: DialogPage.skins,
          ),
          SmallUpperButton(onPressed: widget.onBack, isX: false),
        ],
      ),
    );
  }
}
