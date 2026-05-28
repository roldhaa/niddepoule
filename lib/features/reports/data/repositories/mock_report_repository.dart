import 'dart:async';

import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/features/reports/data/repositories/report_repository.dart';

class MockReportRepository implements ReportRepository {
  final _controller = StreamController<List<Report>>.broadcast();
  final List<Report> _reports = [];

  MockReportRepository() {
    _controller.add(_reports);
  }

  @override
  Stream<List<Report>> watchRecentReports() => _controller.stream;

  @override
  Future<Report> createReport(CreateReportInput input) async {
    final now = DateTime.now();
    final report = Report(
      id: now.microsecondsSinceEpoch.toString(),
      userId: input.userId,
      potholeId: input.potholeId,
      latitude: input.latitude,
      longitude: input.longitude,
      geohash: input.geohash,
      description: input.description,
      photoUrl: input.photoFile?.path,
      dangerLevel: input.dangerLevel,
      aiValidationStatus: AiValidationStatus.pending,
      aiDangerScore: 0,
      status: 'open',
      duplicateGroupId: input.potholeId,
      createdAt: now,
      updatedAt: now,
      city: input.city,
    );
    _reports.insert(0, report);
    _controller.add(List<Report>.from(_reports));
    return report;
  }

  void updateReport(Report report) {
    final index = _reports.indexWhere((r) => r.id == report.id);
    if (index == -1) return;
    _reports[index] = report;
    _controller.add(List<Report>.from(_reports));
  }
}
