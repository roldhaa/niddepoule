import 'package:niddepoule/core/utils/firestore_mapper.dart';

/// Profil utilisateur CivicRoad (UserModel).
class UserProfile {
  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.bio = '',
    this.xp = 0,
    this.reportsCount = 0,
    this.badges = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String bio;
  final int xp;
  final int reportsCount;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? bio,
    String? photoUrl,
    int? xp,
    int? reportsCount,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      xp: xp ?? this.xp,
      reportsCount: reportsCount ?? this.reportsCount,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'xp': xp,
        'reportsCount': reportsCount,
        'badges': badges,
        'createdAt': FirestoreMapper.timestampFromDate(createdAt),
        'updatedAt': FirestoreMapper.timestampFromDate(updatedAt),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfile(
      uid: map['uid'] as String? ?? id ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String? ?? '',
      xp: FirestoreMapper.intFromDynamic(map['xp']),
      reportsCount: FirestoreMapper.intFromDynamic(map['reportsCount']),
      badges: FirestoreMapper.stringListFromDynamic(map['badges']),
      createdAt: FirestoreMapper.dateFromDynamic(map['createdAt']),
      updatedAt: FirestoreMapper.dateFromDynamic(map['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'xp': xp,
        'reportsCount': reportsCount,
        'badges': badges,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      UserProfile.fromMap(json, id: json['uid'] as String?);
}

typedef UserModel = UserProfile;
