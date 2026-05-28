import 'package:niddepoule/core/utils/firestore_mapper.dart';

/// Commentaire sur un signalement (CommentModel).
class AppComment {
  AppComment({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String reportId;
  final String userId;
  final String text;
  final DateTime createdAt;

  AppComment copyWith({
    String? id,
    String? reportId,
    String? userId,
    String? text,
    DateTime? createdAt,
  }) {
    return AppComment(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'reportId': reportId,
        'userId': userId,
        'text': text,
        'createdAt': FirestoreMapper.timestampFromDate(createdAt),
      };

  factory AppComment.fromMap(Map<String, dynamic> map, {required String id}) {
    return AppComment(
      id: id,
      reportId: map['reportId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: FirestoreMapper.dateFromDynamic(map['createdAt']),
    );
  }
}

typedef CommentModel = AppComment;
