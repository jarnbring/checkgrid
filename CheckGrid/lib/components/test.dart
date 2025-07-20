import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomColorSelectionHandle extends TextSelectionControls {
  CustomColorSelectionHandle({
    required this.handleColor,
    this.toolbarColor,
    this.cursorColor,
  }) : _controls =
           Platform.isIOS
               ? cupertinoTextSelectionControls
               : materialTextSelectionControls;

  final Color handleColor;
  final Color? toolbarColor;
  final Color? cursorColor;
  final TextSelectionControls _controls;

  /// Wrap the given handle builder with the needed theme data for
  /// each platform to modify the color.
  Widget _wrapWithThemeData(Widget Function(BuildContext) builder) {
    if (Platform.isIOS) {
      // iOS handle uses the CupertinoTheme primary color, so override that.
      return CupertinoTheme(
        data: CupertinoThemeData(primaryColor: handleColor),
        child: Builder(builder: builder),
      );
    } else {
      // Material handle uses the selection handle color, so override that.
      return TextSelectionTheme(
        data: TextSelectionThemeData(
          selectionHandleColor: handleColor,
          cursorColor: cursorColor,
        ),
        child: Builder(builder: builder),
      );
    }
  }

  /// Wrap toolbar with theme data if custom toolbar color is provided
  Widget _wrapToolbarWithThemeData(Widget Function(BuildContext) builder) {
    if (toolbarColor == null) {
      return Builder(builder: builder);
    }

    if (Platform.isIOS) {
      return CupertinoTheme(
        data: CupertinoThemeData(scaffoldBackgroundColor: toolbarColor),
        child: Builder(builder: builder),
      );
    } else {
      return Theme(
        data: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: handleColor,
            cursorColor: cursorColor,
          ),
          // Customize toolbar appearance
          cardColor: toolbarColor,
        ),
        child: Builder(builder: builder),
      );
    }
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    return _wrapWithThemeData(
      (BuildContext context) =>
          _controls.buildHandle(context, type, textLineHeight, onTap),
    );
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return _controls.getHandleAnchor(type, textLineHeight);
  }

  @override
  Size getHandleSize(double textLineHeight) {
    return _controls.getHandleSize(textLineHeight);
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return _wrapToolbarWithThemeData(
      (BuildContext context) => _controls.buildToolbar(
        context,
        globalEditableRegion,
        textLineHeight,
        selectionMidpoint,
        endpoints,
        delegate,
        clipboardStatus,
        lastSecondaryTapDownPosition,
      ),
    );
  }

  @override
  bool canCopy(TextSelectionDelegate delegate) {
    return _controls.canCopy(delegate);
  }

  @override
  bool canCut(TextSelectionDelegate delegate) {
    return _controls.canCut(delegate);
  }

  @override
  bool canPaste(TextSelectionDelegate delegate) {
    return _controls.canPaste(delegate);
  }

  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    return _controls.canSelectAll(delegate);
  }

  @override
  void handleCopy(TextSelectionDelegate delegate) {
    _controls.handleCopy(delegate);
  }

  @override
  void handleCut(TextSelectionDelegate delegate) {
    _controls.handleCut(delegate);
  }

  @override
  void handleSelectAll(TextSelectionDelegate delegate) {
    _controls.handleSelectAll(delegate);
  }
}
