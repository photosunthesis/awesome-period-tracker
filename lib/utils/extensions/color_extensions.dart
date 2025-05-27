import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color darken([double? amount]) {
    if (amount == null) {
      return this;
    }

    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    final hslDarkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );

    return hslDarkened.toColor();
  }

  Color lighten([double? amount]) {
    if (amount == null) {
      return this;
    }

    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');

    final hsl = HSLColor.fromColor(this);
    final hslLightened = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return hslLightened.toColor();
  }
}
