import 'package:checkgrid/animations/border_beam.dart';
import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/pages/store/components/new.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';

class SkinItem extends StatefulWidget {
  final Skin skin;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final Widget? child;

  const SkinItem({
    super.key,
    required this.skin,
    required this.isUnlocked,
    this.onTap,
    this.child,
  });
  @override
  State<SkinItem> createState() => _SkinItemState();
}

class _SkinItemState extends State<SkinItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BorderBeam(
            duration: 3,
            colorFrom: const Color.fromARGB(255, 2, 255, 103),
            colorTo: const Color.fromARGB(255, 0, 213, 255),
            staticBorderColor: const Color.fromARGB(185, 255, 255, 255),
            borderRadius: BorderRadius.circular(16),
            borderWidth: 4,
            child: Container(
              alignment: Alignment.center,
              width: 150,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pieces/${widget.skin.name}/${widget.skin.name}_bishop.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    widget.isUnlocked
                        ? OutlinedText(text: 'Owned')
                        : widget.child ??
                            OutlinedText(
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
