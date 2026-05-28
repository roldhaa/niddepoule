import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

final potholeByIdProvider =
    FutureProvider.family<Pothole?, String>((ref, id) async {
  return ref.read(potholeServiceProvider).getById(id);
});

final potholeReportsProvider =
    StreamProvider.family<List<Report>, String>((ref, potholeId) {
  return ref.read(reportServiceProvider).watchReportsForPothole(potholeId);
});
