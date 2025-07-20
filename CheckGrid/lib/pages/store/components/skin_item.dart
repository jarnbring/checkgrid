import 'package:checkgrid/animations/border_beam.dart';
import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/pages/store/components/new.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SkinItem extends StatefulWidget {
  final Skin skin;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const SkinItem({
    super.key,
    required this.skin,
    required this.isUnlocked,
    this.onTap,
  });
  @override
  State<SkinItem> createState() => _SkinItemState();
}

class _SkinItemState extends State<SkinItem> {
  @override
  Widget build(BuildContext context) {
    final generalProvider = context.watch<GeneralProvider>();

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BorderBeam(
            duration: 4,
            colorFrom: const Color.fromARGB(255, 255, 251, 2),
            colorTo: const Color.fromARGB(255, 0, 51, 255),
            staticBorderColor: const Color.fromARGB(255, 0, 0, 251),
            borderRadius: BorderRadius.circular(16),
            borderWidth: 2,
            child: Container(
              alignment: Alignment.center,
              width: generalProvider.screenWidth(context) / 3.3,
              decoration: BoxDecoration(
                color:
                    widget.isUnlocked
                        ? const Color.fromARGB(255, 26, 132, 231)
                        : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isUnlocked ? Colors.amber : Colors.grey,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 24, 10, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pieces/${widget.skin.name}/${widget.skin.name}_bishop.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    widget.isUnlocked
                        ? OutlinedText(text: 'Owned')
                        : OutlinedText(
                          text: widget.skin.price.toString(),
                          isPrice: true,
                        ),
                  ],
                ),
              ),
            ),
          ),
          widget.skin.isNew ? NewWidget() : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
