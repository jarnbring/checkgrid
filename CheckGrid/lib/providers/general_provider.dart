import 'package:flutter/material.dart';

class GeneralProvider with ChangeNotifier {
  double _scaleFactor = 1.0;

  double get scaleFactor => _scaleFactor;

  void setScaleFactor(double factor) {
    _scaleFactor = factor.clamp(0.5, 2.0);
    notifyListeners();
  }

  double getResponsiveSize(double baseSize, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    // Begränsa skalning för stora skärmar
    final maxScaleFactor = 2.5; // Max 2.5x skalning
    final widthFactor = (screenWidth / 375).clamp(0.5, maxScaleFactor);
    // Justera för DPI
    final dpiAdjustedFactor = widthFactor / (devicePixelRatio / 2.0);
    return baseSize * _scaleFactor * dpiAdjustedFactor.clamp(0.5, 2.0);
  }

  double getResponsivePadding(double basePadding, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final maxScaleFactor = 2.5;
    final widthFactor = (screenWidth / 375).clamp(0.5, maxScaleFactor);
    final dpiAdjustedFactor = widthFactor / (devicePixelRatio / 2.0);
    return basePadding * _scaleFactor * dpiAdjustedFactor.clamp(0.5, 2.0);
  }

  double getResponsiveVerticalPadding(double basePadding, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final widthFactor = screenWidth / 375;
    final heightFactor = screenHeight / 844;
    final factor = widthFactor < heightFactor ? widthFactor : heightFactor;
    final maxScaleFactor = 2.0;
    final dpiAdjustedFactor = (factor / (devicePixelRatio / 2.0)).clamp(0.5, maxScaleFactor);
    return (basePadding * _scaleFactor * dpiAdjustedFactor).clamp(basePadding * 0.5, basePadding * 1.5);
  }

  double getResponsiveCellSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final padding = getResponsivePadding(10, context) * 2; // Minskat från * 4
    final spacing = getResponsiveSize(3, context) * 7;
    final availableWidth = screenWidth - (2 * padding) - spacing;
    // Begränsa cellstorlek för stora skärmar
    return (availableWidth / 8).clamp(30.0, 60.0); // Minskat max från 70 till 60
  }

  double getResponsiveAppBarHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    const minHeight = 50.0; // iPhone
    const maxHeight = 80.0; // Minskat från 100 till 80 för Pixel Tablet
    const minWidth = 375.0;
    const maxWidth = 1024.0;
    final t = (screenWidth - minWidth) / (maxWidth - minWidth);
    final height = minHeight + (maxHeight - minHeight) * t.clamp(0.0, 1.0);
    // Justera för DPI
    final dpiAdjustedHeight = height / (devicePixelRatio / 2.0);
    return dpiAdjustedHeight.clamp(minHeight, maxHeight);
  }
}