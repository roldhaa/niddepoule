import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_loader.dart';
import 'package:niddepoule/core/widgets/civic_text_field.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';
import 'package:niddepoule/features/comments/presentation/providers/comments_providers.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  const CommentsBottomSheet({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = ref.read(currentUserProvider);
    final text = _controller.text.trim();
    if (user == null || text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(commentServiceProvider).addComment(
            reportId: widget.reportId,
            userId: user.uid,
            text: text,
          );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(reportCommentsProvider(widget.reportId));
    final user = ref.watch(currentUserProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Commentaires',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: comments.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const CivicEmptyState(
                        title: 'Aucun commentaire',
                        subtitle: 'Soyez le premier à réagir.',
                        icon: Icons.chat_bubble_outline,
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final c = items[index];
                        final isMine = user?.uid == c.userId;
                        return ListTile(
                          title: Text(c.text),
                          subtitle: Text(c.userId),
                          trailing: isMine
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(commentServiceProvider)
                                          .deleteOwnComment(
                                            commentId: c.id,
                                            userId: user!.uid,
                                          );
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('$e')),
                                        );
                                      }
                                    }
                                  },
                                )
                              : null,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CivicLoader()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CivicTextField(
                        controller: _controller,
                        label: 'Commentaire',
                        hint: 'Votre message...',
                        maxLines: 3,
                      ),
                    ),
                    AppSpacing.gapH(AppSpacing.sm),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
