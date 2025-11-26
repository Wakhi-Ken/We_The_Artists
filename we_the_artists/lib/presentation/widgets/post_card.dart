import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

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
  bool _showLikeAnimation = false;
  late PageController _pageController;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, AudioPlayer> _audioPlayers = {};

  List<String> _comments = [];
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
    setState(() => _showLikeAnimation = true);
    _likeAnimationController.forward();
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
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_comments[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() => _comments.removeAt(index));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        setState(() {
                          _comments.add(_commentController.text.trim());
                          _commentController.clear();
                        });
                      }
                    },
                    child: const Text('Add Comment'),
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
            // User info + delete option
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
            // Post content
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
            // Media PageView
            if (widget.post.imageUrls.isNotEmpty ||
                widget.post.videoUrls.isNotEmpty ||
                widget.post.audioUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount:
                      widget.post.imageUrls.length +
                      widget.post.videoUrls.length +
                      widget.post.audioUrls.length,
                  itemBuilder: (context, index) {
                    if (index < widget.post.imageUrls.length) {
                      final url = widget.post.imageUrls[index];
                      return GestureDetector(
                        onDoubleTap: _handleDoubleTap,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else if (index <
                        widget.post.imageUrls.length +
                            widget.post.videoUrls.length) {
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
                    return const SizedBox();
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
                    children: const [
                      Icon(Icons.comment_outlined, size: 20),
                      SizedBox(width: 4),
                      Text('0'),
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
