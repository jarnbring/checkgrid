import 'package:checkgrid/animations/border_beam.dart';
import 'package:checkgrid/components/outlined_text.dart';
import 'package:checkgrid/pages/store/components/new.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:checkgrid/providers/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SkinItem extends StatefulWidget {
  final Skin skin;
  final bool unlocked;
  final bool isNew;
  final String? unlockText;
  final VoidCallback? onTap;

  const SkinItem({
    super.key,
    required this.skin,
    required this.unlocked,
    this.isNew = false,
    this.unlockText,
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
              width: generalProvider.screenWidth(context) / 3,
              decoration: BoxDecoration(
                color:
                    widget.unlocked ? Colors.blueAccent : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.unlocked ? Colors.amber : Colors.grey,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 8, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/pieces/${widget.imageName}/${widget.imageName}_bishop.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        OutlinedText(text: widget.skin.name),

                        if (!widget.unlocked && widget.unlockText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.unlockText!,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 9,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.isNew ? NewWidget() : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
