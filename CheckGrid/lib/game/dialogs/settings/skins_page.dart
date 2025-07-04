import 'package:checkgrid/game/dialogs/settings/components/dialog_image.dart';
import 'package:checkgrid/game/dialogs/settings/components/small_button.dart';
import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/game/board.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final skinProvider = context.watch<SkinProvider>();
    final skinKeys = skinProvider.allSkins.keys.toList();
    final selectedSkinKey = skinProvider.selectedSkin;

    skinProvider.unlockSkin('black');

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
                            mainAxisSpacing: 30,
                            crossAxisSpacing: 30,
                            childAspectRatio: 1,
                          ),
                      itemCount: skinKeys.length,
                      itemBuilder: (context, index) {
                        final skinName = skinKeys[index];
                        final isSelected = skinName == selectedSkinKey;
                        final isUnlocked = skinProvider.unlockedSkins.contains(
                          skinName,
                        );

                        return GestureDetector(
                          onTap:
                              isUnlocked
                                  ? () {
                                    skinProvider.selectSkin(skinName);
                                  }
                                  : null,
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
                              child: Opacity(
                                opacity: isUnlocked ? 1.0 : 0.1,
                                child: Image.asset(
                                  "assets/images/pieces/$skinName/${skinName}_knight.png",
                                ),
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
