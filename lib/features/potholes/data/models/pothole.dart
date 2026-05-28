import 'package:niddepoule/core/utils/firestore_mapper.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

/// Agregat nid-de-poule (PotholeModel).
class Pothole {
  Pothole({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    required this.dangerLevel,
    required this.reportCount,
    required this.status,
    required this.firstReportedAt,
    required this.lastReportedAt,
    this.photoUrls = const [],
    this.city,
    this.repairedAt,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String geohash;
  final DangerLevel dangerLevel;
  final int reportCount;
  final String status;
  final DateTime firstReportedAt;
  final DateTime lastReportedAt;
  final List<String> photoUrls;
  final String? city;
  final DateTime? repairedAt;

  Pothole copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? geohash,
    DangerLevel? dangerLevel,
    int? reportCount,
    String? status,
    DateTime? firstReportedAt,
    DateTime? lastReportedAt,
    List<String>? photoUrls,
    String? city,
    DateTime? repairedAt,
  }) {
    return Pothole(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      reportCount: reportCount ?? this.reportCount,
      status: status ?? this.status,
      firstReportedAt: firstReportedAt ?? this.firstReportedAt,
      lastReportedAt: lastReportedAt ?? this.lastReportedAt,
      photoUrls: photoUrls ?? this.photoUrls,
      city: city ?? this.city,
      repairedAt: repairedAt ?? this.repairedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'geohash': geohash,
        'dangerLevel': dangerLevel.name,
        'reportCount': reportCount,
        'status': status,
        'firstReportedAt': FirestoreMapper.timestampFromDate(firstReportedAt),
        'lastReportedAt': FirestoreMapper.timestampFromDate(lastReportedAt),
        'photoUrls': photoUrls,
        'city': city,
        'repairedAt': FirestoreMapper.timestampFromNullableDate(repairedAt),
      };

  factory Pothole.fromMap(Map<String, dynamic> map, {required String id}) {
    return Pothole(
      id: id,
      latitude: FirestoreMapper.doubleFromDynamic(map['latitude']),
      longitude: FirestoreMapper.doubleFromDynamic(map['longitude']),
      geohash: map['geohash'] as String? ?? '',
      dangerLevel: DangerLevel.values.firstWhere(
        (l) => l.name == map['dangerLevel'],
        orElse: () => DangerLevel.medium,
      ),
      reportCount: FirestoreMapper.intFromDynamic(map['reportCount'], fallback: 1),
      status: map['status'] as String? ?? 'open',
      firstReportedAt: FirestoreMapper.dateFromDynamic(map['firstReportedAt']),
      lastReportedAt: FirestoreMapper.dateFromDynamic(map['lastReportedAt']),
      photoUrls: FirestoreMapper.stringListFromDynamic(map['photoUrls']),
      city: map['city'] as String?,
      repairedAt: map['repairedAt'] == null
          ? null
          : FirestoreMapper.dateFromDynamic(map['repairedAt']),
    );
  }
}

typedef PotholeModel = Pothole;
