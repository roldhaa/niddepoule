import 'package:niddepoule/core/utils/firestore_mapper.dart';

enum DangerLevel { low, medium, high }

enum AiValidationStatus { pending, approved, rejected }

/// Signalement individuel (ReportModel).
class Report {
  Report({
    required this.id,
    required this.userId,
    required this.potholeId,
    required this.latitude,
    required this.longitude,
    required this.geohash,
    this.description,
    this.photoUrl,
    required this.dangerLevel,
    required this.aiValidationStatus,
    required this.aiDangerScore,
    required this.status,
    this.duplicateGroupId,
    required this.createdAt,
    required this.updatedAt,
    this.city,
  });

  final String id;
  final String userId;
  final String potholeId;
  final double latitude;
  final double longitude;
  final String geohash;
  final String? description;
  final String? photoUrl;
  final DangerLevel dangerLevel;
  final AiValidationStatus aiValidationStatus;
  final int aiDangerScore;
  final String status;
  final String? duplicateGroupId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? city;

  Report copyWith({
    String? id,
    String? userId,
    String? potholeId,
    double? latitude,
    double? longitude,
    String? geohash,
    String? description,
    String? photoUrl,
    DangerLevel? dangerLevel,
    AiValidationStatus? aiValidationStatus,
    int? aiDangerScore,
    String? status,
    String? duplicateGroupId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? city,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      potholeId: potholeId ?? this.potholeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      aiValidationStatus: aiValidationStatus ?? this.aiValidationStatus,
      aiDangerScore: aiDangerScore ?? this.aiDangerScore,
      status: status ?? this.status,
      duplicateGroupId: duplicateGroupId ?? this.duplicateGroupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'potholeId': potholeId,
        'latitude': latitude,
        'longitude': longitude,
        'geohash': geohash,
        'description': description,
        'photoUrl': photoUrl,
        'dangerLevel': dangerLevel.name,
        'aiValidationStatus': aiValidationStatus.name,
        'aiDangerScore': aiDangerScore,
        'status': status,
        'duplicateGroupId': duplicateGroupId,
        'createdAt': FirestoreMapper.timestampFromDate(createdAt),
        'updatedAt': FirestoreMapper.timestampFromDate(updatedAt),
        'city': city,
      };

  factory Report.fromMap(Map<String, dynamic> map, {required String id}) {
    return Report(
      id: id,
      userId: map['userId'] as String? ?? '',
      potholeId: map['potholeId'] as String? ??
          (map['duplicateGroupId'] as String? ?? ''),
      latitude: FirestoreMapper.doubleFromDynamic(map['latitude']),
      longitude: FirestoreMapper.doubleFromDynamic(map['longitude']),
      geohash: map['geohash'] as String? ?? '',
      description: map['description'] as String?,
      photoUrl: map['photoUrl'] as String?,
      dangerLevel: DangerLevel.values.firstWhere(
        (l) => l.name == map['dangerLevel'],
        orElse: () => DangerLevel.medium,
      ),
      aiValidationStatus: AiValidationStatus.values.firstWhere(
        (s) => s.name == map['aiValidationStatus'],
        orElse: () => AiValidationStatus.pending,
      ),
      aiDangerScore: FirestoreMapper.intFromDynamic(map['aiDangerScore']),
      status: map['status'] as String? ?? 'open',
      duplicateGroupId: map['duplicateGroupId'] as String?,
      createdAt: FirestoreMapper.dateFromDynamic(map['createdAt']),
      updatedAt: FirestoreMapper.dateFromDynamic(map['updatedAt']),
      city: map['city'] as String?,
    );
  }

  /// Compatibilite avec l ancien code.
  Map<String, dynamic> toJson() => {
        ...toMap(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

typedef ReportModel = Report;
