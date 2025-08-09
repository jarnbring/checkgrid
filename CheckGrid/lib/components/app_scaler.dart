import 'dart:math';

import 'package:flutter/material.dart';

/// AppScaler keeps your UI proportions exactly as designed by
/// rendering the whole app on a fixed-size canvas and scaling it
/// uniformly to fit the current device (portrait only).
///
/// Update [designSize] if your reference device differs.
class AppScaler extends StatelessWidget {
  const AppScaler({
    super.key,
    required this.child,
    this.designSize = const Size(400, 870), // iPhone 12/13/14 reference
    this.alignment = Alignment.topCenter,
    this.backgroundColor,
  });

  final Widget? child;
  final Size designSize;
  final Alignment alignment;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // Uniform scale to keep proportions
        final double scale = min(
          screenWidth / designSize.width,
          screenHeight / designSize.height,
        );

        final double scaledWidth = designSize.width * scale;
        final double scaledHeight = designSize.height * scale;

        final Color bg = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

        return ColoredBox(
          color: bg,
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
                    // Disable dynamic text scaling to keep exact proportions
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


