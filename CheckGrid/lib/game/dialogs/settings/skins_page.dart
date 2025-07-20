import 'package:checkgrid/game/dialogs/settings/components/dialog_image.dart';
import 'package:checkgrid/game/dialogs/settings/components/small_button.dart';
import 'package:checkgrid/game/dialogs/settings/settings_dialog.dart';
import 'package:checkgrid/providers/settings_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/game/board.dart';
import 'package:provider/provider.dart';

class SkinsPage extends StatefulWidget {
  final Board board;
  final VoidCallback onBack;
  final double dialogWidth;
  final double dialogHeight;

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
    final unlockedSkins = skinProvider.unlockedSkins;
    final selectedSkin = skinProvider.selectedSkin;

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
                  const DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    child: Text("Select Skin"),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 40,
                            crossAxisSpacing: 40,
                            childAspectRatio: 1,
                          ),
                      itemCount: unlockedSkins.length,
                      itemBuilder: (context, index) {
                        final skin = unlockedSkins[index];
                        final isSelected = skin == selectedSkin;
                        return GestureDetector(
                          onTap:
                              () => {
                                context.read<SettingsProvider>().doVibration(1),
                                skinProvider.selectSkin(skin),
                              },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 16, 79, 131),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected ? Colors.lightBlue : Colors.grey,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/images/pieces/${skin.name}/${skin.name}_knight.png",
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
