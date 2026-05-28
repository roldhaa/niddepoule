import 'package:flutter/material.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';

export 'package:niddepoule/core/widgets/civic_empty_state.dart';

/// Retrocompatibilite : ancien API `message` -> `title`.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required String message,
    String? subtitle,
    IconData icon = Icons.inbox_outlined,
  }) : _title = message,
       _subtitle = subtitle,
       _icon = icon;

  final String _title;
  final String? _subtitle;
  final IconData _icon;

  @override
  Widget build(BuildContext context) {
    return CivicEmptyState(
      title: _title,
      subtitle: _subtitle,
      icon: _icon,
    );
  }
}
