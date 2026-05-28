import 'package:niddepoule/features/comments/data/models/comment.dart';

abstract class CommentRepository {
  Stream<List<AppComment>> watchComments(String reportId);
  Future<void> addComment({
    required String reportId,
    required String userId,
    required String text,
  });
}
