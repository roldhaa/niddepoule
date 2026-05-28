import 'package:flutter/material.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class DangerColors {
  static Color forLevel(DangerLevel level) {
    return switch (level) {
      DangerLevel.low => Colors.green,
      DangerLevel.medium => Colors.orange,
      DangerLevel.high => Colors.red,
    };
  }

  static String label(DangerLevel level) {
    return switch (level) {
      DangerLevel.low => 'Faible',
      DangerLevel.medium => 'Moyen',
      DangerLevel.high => 'Eleve',
    };
  }
}
