import 'package:flutter/material.dart';

/// Échelle d'espacement 4pt.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const screenPadding = EdgeInsets.symmetric(horizontal: lg);
  static const cardPadding = EdgeInsets.all(lg);

  static SizedBox gapH(double w) => SizedBox(width: w);
  static SizedBox gapV(double h) => SizedBox(height: h);

  static const vXs = SizedBox(height: xs);
  static const vSm = SizedBox(height: sm);
  static const vMd = SizedBox(height: md);
  static const vLg = SizedBox(height: lg);
  static const vXl = SizedBox(height: xl);
}
