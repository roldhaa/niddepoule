import 'package:flutter/material.dart';
import 'package:niddepoule/core/widgets/civic_danger_tag.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

/// Retrocompatibilite — preferer [CivicDangerTag].
class DangerBadge extends StatelessWidget {
  const DangerBadge({super.key, required this.level});

  final DangerLevel level;

  @override
  Widget build(BuildContext context) => CivicDangerTag(level: level);
}
