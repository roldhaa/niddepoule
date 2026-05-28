import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/core/utils/danger_colors.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class CivicDangerTag extends StatelessWidget {
  const CivicDangerTag({
    super.key,
    required this.level,
    this.compact = false,
  });

  final DangerLevel level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = DangerColors.forLevel(level);
    final label = DangerColors.label(level);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
