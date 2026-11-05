import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double getWidthPercentage(BuildContext context, double percentage) =>
      screenWidth(context) * (percentage / 100);

  static double getHeightPercentage(BuildContext context, double percentage) =>
      screenHeight(context) * (percentage / 100);

  // Responsive font sizes
  static double getSmallFontSize(BuildContext context) =>
      screenWidth(context) * 0.03;

  static double getMediumFontSize(BuildContext context) =>
      screenWidth(context) * 0.04;

  static double getLargeFontSize(BuildContext context) =>
      screenWidth(context) * 0.05;

  // Responsive sizing helpers
  static double getSmallSpacing(BuildContext context) =>
      screenHeight(context) * 0.01;

  static double getMediumSpacing(BuildContext context) =>
      screenHeight(context) * 0.02;

  static double getLargeSpacing(BuildContext context) =>
      screenHeight(context) * 0.03;

  // Flexible avatar size
  static double getAvatarRadius(BuildContext context) =>
      getWidthPercentage(context, 8);

  // Responsive button height
  static double getButtonHeight(BuildContext context) =>
      screenHeight(context) * 0.06;
}