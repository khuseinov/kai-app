import 'package:flutter/material.dart';

/// Semantic border radius tokens
class KaiRadii {
  // Raw values
  static const double sRaw = 8.0;
  static const double mRaw = 12.0;
  static const double lRaw = 16.0;
  static const double xlRaw = 24.0;
  static const double pillRaw = 999.0;

  // BorderRadius objects
  static const BorderRadius s = BorderRadius.all(Radius.circular(sRaw));
  static const BorderRadius m = BorderRadius.all(Radius.circular(mRaw));
  static const BorderRadius l = BorderRadius.all(Radius.circular(lRaw));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlRaw));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(pillRaw));

  // Semantic
  static const BorderRadius card = BorderRadius.all(Radius.circular(24.0));
  static const BorderRadius button = BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius bottomSheet =
      BorderRadius.vertical(top: Radius.circular(32.0));
}
