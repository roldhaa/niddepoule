import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/features/comments/data/models/comment.dart';
import 'package:niddepoule/features/comments/data/repositories/comment_repository.dart';

class FirebaseCommentRepository implements CommentRepository {
  FirebaseCommentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('comments');

  @override
  Stream<List<AppComment>> watchComments(String reportId) {
    return _comments
        .where('reportId', isEqualTo: reportId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppComment.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<void> addComment({
    required String reportId,
    required String userId,
    required String text,
  }) async {
    await _comments.add({
      'reportId': reportId,
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final doc = await _comments.doc(commentId).get();
    if (!doc.exists) return;
    if (doc.data()?['userId'] != userId) {
      throw StateError('Vous ne pouvez supprimer que vos commentaires.');
    }
    await _comments.doc(commentId).delete();
  }
}
