import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/features/comments/data/models/comment.dart';
import 'package:niddepoule/features/comments/data/repositories/comment_repository.dart';
import 'package:niddepoule/features/comments/data/repositories/firebase_comment_repository.dart';

class CommentService {
  CommentService(FirebaseFirestore firestore)
      : _repository = FirebaseCommentRepository(firestore);

  final CommentRepository _repository;

  Stream<List<AppComment>> watchComments(String reportId) =>
      _repository.watchComments(reportId);

  Future<void> addComment({
    required String reportId,
    required String userId,
    required String text,
  }) =>
      _repository.addComment(
        reportId: reportId,
        userId: userId,
        text: text,
      );

  Future<void> deleteOwnComment({
    required String commentId,
    required String userId,
  }) async {
    final repo = _repository;
    if (repo is FirebaseCommentRepository) {
      await repo.deleteComment(commentId: commentId, userId: userId);
    }
  }
}
