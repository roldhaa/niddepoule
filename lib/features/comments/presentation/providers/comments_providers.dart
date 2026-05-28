import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/comments/data/models/comment.dart';

final reportCommentsProvider =
    StreamProvider.family<List<AppComment>, String>((ref, reportId) {
  return ref.watch(commentServiceProvider).watchComments(reportId);
});
