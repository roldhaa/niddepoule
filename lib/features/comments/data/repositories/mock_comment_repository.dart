import 'dart:async';

import 'package:niddepoule/features/comments/data/models/comment.dart';
import 'package:niddepoule/features/comments/data/repositories/comment_repository.dart';

class MockCommentRepository implements CommentRepository {
  final List<AppComment> _comments = [];
  final _controller = StreamController<void>.broadcast();

  @override
  Stream<List<AppComment>> watchComments(String reportId) async* {
    yield _filter(reportId);
    await for (final _ in _controller.stream) {
      yield _filter(reportId);
    }
  }

  List<AppComment> _filter(String reportId) =>
      _comments.where((c) => c.reportId == reportId).toList();

  @override
  Future<void> addComment({
    required String reportId,
    required String userId,
    required String text,
  }) async {
    _comments.add(
      AppComment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        reportId: reportId,
        userId: userId,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    _controller.add(null);
  }

  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;
    if (_comments[index].userId != userId) {
      throw StateError('Vous ne pouvez supprimer que vos commentaires.');
    }
    _comments.removeAt(index);
    _controller.add(null);
  }
}
