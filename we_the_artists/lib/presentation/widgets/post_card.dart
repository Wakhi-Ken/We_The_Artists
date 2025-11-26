import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/post_entity.dart';
import 'package:we_the_artists/presentation/bloc/post_bloc.dart';
import 'package:we_the_artists/presentation/bloc/post_event.dart';
import '../screens/artist_profile_screen.dart';
import '../utils/avatar_gradients.dart';
import '../utils/mention_text_helper.dart';
import '../utils/time_helper.dart';
import '../widgets/animated_gradient_avatar.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final bool isOwnPost;

  const PostCard({Key? key, required this.post, this.isOwnPost = false})
    : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  late PageController _pageController;

  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, AudioPlayer> _audioPlayers = {};
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Initialize video controllers
    for (var url in widget.post.videoUrls) {
      _videoControllers[url] = VideoPlayerController.network(url)
        ..initialize().then((_) => setState(() {}));
    }

    // Initialize audio players
    for (var url in widget.post.audioUrls) {
      _audioPlayers[url] = AudioPlayer()..setUrl(url);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimationController.dispose();
    for (var controller in _videoControllers.values) controller.dispose();
    for (var player in _audioPlayers.values) player.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!widget.post.isLiked) {
      context.read<PostBloc>().add(ToggleLike(widget.post.id));
    }
    _likeAnimationController.forward(from: 0);
  }

  Future<void> _addComment(String text) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || text.trim().isEmpty) return;

    final postRef = FirebaseFirestore.instance
        .collection('Posts')
        .doc(widget.post.id);
    final commentRef = postRef.collection('comments');

    // Add comment
    await commentRef.add({
      'text': text.trim(),
      'userId': currentUser.uid,
      'userName': currentUser.displayName ?? 'Anonymous',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Increment post's comment count
    await postRef.update({'comments': FieldValue.increment(1)});

    // Add notification for the post owner
    if (currentUser.uid != widget.post.userId) {
      final notificationRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.post.userId)
          .collection('notifications');

      await notificationRef.add({
        'type': 'comment',
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? 'Anonymous',
        'postId': widget.post.id,
        'message': 'commented on your post',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  void _showCommentsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Posts')
                          .doc(widget.post.id)
                          .collection('comments')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final commentDocs = snapshot.data!.docs;
                        if (commentDocs.isEmpty) {
                          return const Center(child: Text("No comments yet"));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: commentDocs.length,
                          itemBuilder: (context, index) {
                            final data =
                                commentDocs[index].data()
                                    as Map<String, dynamic>;
                            return ListTile(
                              title: Text(data['userName'] ?? 'Unknown'),
                              subtitle: Text(data['text'] ?? ''),
                              trailing: Text(
                                TimeHelper.getRelativeTime(
                                  (data['createdAt'] as Timestamp?)?.toDate() ??
                                      DateTime.now(),
                                ),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          if (_commentController.text.trim().isNotEmpty) {
                            await _addComment(_commentController.text.trim());
                            _commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AvatarGradients.getGradientForUser(widget.post.userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ArtistProfileScreen(userId: widget.post.userId),
                      ),
                    );
                  },
                  child: AnimatedGradientAvatar(
                    initials: widget.post.userName
                        .split(' ')
                        .map((n) => n[0])
                        .take(2)
                        .join()
                        .toUpperCase(),
                    size: 48,
                    gradientColors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ArtistProfileScreen(userId: widget.post.userId),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          '${widget.post.userRole} · ${widget.post.userLocation}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isOwnPost)
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        context.read<PostBloc>().add(
                          DeletePostEvent(widget.post.id),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Post'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            RichText(
              text: MentionTextHelper.buildMentionText(
                widget.post.content,
                context,
                baseStyle: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (widget.post.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: widget.post.tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        backgroundColor: theme.dividerColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            // Media
            if (widget.post.imageUrls.isNotEmpty ||
                widget.post.videoUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount:
                      widget.post.imageUrls.length +
                      widget.post.videoUrls.length,
                  itemBuilder: (context, index) {
                    if (index < widget.post.imageUrls.length) {
                      final url = widget.post.imageUrls[index];
                      return GestureDetector(
                        onDoubleTap: _handleDoubleTap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      );
                    } else {
                      final vidIndex = index - widget.post.imageUrls.length;
                      final url = widget.post.videoUrls[vidIndex];
                      final controller = _videoControllers[url]!;
                      return controller.value.isInitialized
                          ? GestureDetector(
                              onDoubleTap: _handleDoubleTap,
                              child: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              ),
                            )
                          : const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Text(
                  TimeHelper.getRelativeTime(widget.post.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showCommentsDialog,
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.post.comments}'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      context.read<PostBloc>().add(ToggleLike(widget.post.id)),
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.post.isLiked ? Colors.red : null,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${widget.post.likes}'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      context.read<PostBloc>().add(SharePost(widget.post.id)),
                  child: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      context.read<PostBloc>().add(ToggleSave(widget.post.id)),
                  child: Icon(
                    widget.post.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: widget.post.isSaved
                        ? Colors.blue
                        : theme.iconTheme.color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
