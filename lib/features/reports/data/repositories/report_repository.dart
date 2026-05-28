import 'dart:io';

import 'package:niddepoule/features/reports/data/models/report.dart';

class CreateReportInput {
  CreateReportInput({
    required this.userId,
    this.potholeId = '',
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.dangerLevel,
    this.description,
    this.photoFile,
    this.city,
  });

  final String userId;
  final String potholeId;
  final double latitude;
  final double longitude;
  final String geohash;
  final DangerLevel dangerLevel;
  final String? description;
  final File? photoFile;
  final String? city;
}

abstract class ReportRepository {
  Stream<List<Report>> watchRecentReports();
  Future<Report> createReport(CreateReportInput input);
}
