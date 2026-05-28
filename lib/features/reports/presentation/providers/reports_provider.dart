import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

/// Flux des signalements recents.
final reportsProvider = StreamProvider<List<Report>>((ref) {
  return ref.watch(reportServiceProvider).watchRecentReports();
});
