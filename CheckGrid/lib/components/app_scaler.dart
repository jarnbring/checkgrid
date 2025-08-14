import 'dart:math';
import 'package:checkgrid/components/background.dart';
import 'package:flutter/material.dart';

class AppScaler extends StatelessWidget {
  const AppScaler({
    super.key,
    required this.child,
    this.designSize = const Size(400, 870),
    this.alignment = Alignment.topCenter,
    this.backgroundColor,
    this.useCustomBackground = false,
    this.gradient,
  });

  final Widget? child;
  final Size designSize;
  final Alignment alignment;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final bool useCustomBackground;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        final double scale = min(
          screenWidth / designSize.width,
          screenHeight / designSize.height,
        );

        final double scaledWidth = designSize.width * scale;
        final double scaledHeight = designSize.height * scale;

        Widget backgroundWidget;
        if (useCustomBackground) {
          // Skapa decoration baserat på om gradient eller färg finns
          BoxDecoration decoration;
          if (gradient != null) {
            // Om gradient finns, använd den
            decoration = BoxDecoration(gradient: gradient, );
          } else if (backgroundColor != null) {
            // Om bara färg finns, använd den
            decoration = BoxDecoration(color: backgroundColor);
          } else {
            // Fallback till tema-färg
            decoration = BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            );
          }

          backgroundWidget = Container(
            constraints: const BoxConstraints.expand(),
            decoration: decoration,
            child: Align(
              alignment: alignment,
              child: SizedBox(
                width: scaledWidth,
                height: scaledHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: designSize.width,
                    height: designSize.height,
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1.0)),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          backgroundWidget = Background(
            child: Align(
              alignment: alignment,
              child: SizedBox(
                width: scaledWidth,
                height: scaledHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: designSize.width,
                    height: designSize.height,
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1.0)),
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return backgroundWidget;
      },
    );
  }
}
