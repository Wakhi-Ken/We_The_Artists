import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/post_entity.dart';
import 'package:we_the_artists/presentation/bloc/post_bloc.dart';
import 'package:we_the_artists/presentation/bloc/post_event.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_state.dart';
import '../bloc/comment_event.dart';
import '../screens/artist_profile_screen.dart';
import '../utils/avatar_gradients.dart';
import '../utils/mention_text_helper.dart';
import '../utils/time_helper.dart';
import '../widgets/animated_gradient_avatar.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final bool isOwnPost;

  const PostCard({super.key, required this.post, this.isOwnPost = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showLikeAnimation = false;
  int _currentMediaIndex = 0;
  late PageController _pageController;
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<String, AudioPlayer> _audioPlayers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Like animation
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
    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showLikeAnimation = false);
        _likeAnimationController.reset();
      }
    });

    // Init videos
    for (var url in widget.post.videoUrls) {
      final controller = VideoPlayerController.network(url)
        ..initialize().then((_) => setState(() {}));
      _videoControllers[url] = controller;
    }

    // Init audios
    for (var url in widget.post.audioUrls) {
      final player = AudioPlayer();
      player.setUrl(url);
      _audioPlayers[url] = player;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimationController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!widget.post.isLiked) {
      context.read<PostBloc>().add(ToggleLike(widget.post.id));
    }
    setState(() => _showLikeAnimation = true);
    _likeAnimationController.forward();
  }

  void _showCommentsSheet(BuildContext context) {
    context.read<CommentBloc>().add(LoadComments(widget.post.id));
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              // Comment List
              Expanded(
                child: BlocProvider.value(
                  value: context
                      .read<CommentBloc>(), // Provide CommentBloc here
                  child: BlocBuilder<CommentBloc, CommentState>(
                    builder: (context, state) {
                      if (state is CommentLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CommentLoaded) {
                        if (state.comments.isEmpty) {
                          return const Center(
                            child: Text(
                              'No comments yet. Be the first!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.blue, Colors.purple],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        comment.userName
                                            .split(' ')
                                            .map((n) => n[0])
                                            .take(2)
                                            .join()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.content,
                                          style: const TextStyle(fontSize: 14),
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
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              // Input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          context.read<CommentBloc>().add(
                            AddComment(
                              postId: widget.post.id,
                              content: commentController.text.trim(),
                            ),
                          );
                          commentController.clear();
                        }
                      },
                      icon: const Icon(Icons.send, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            // User info
            Row(
              children: [
                GestureDetector(
                  onTap: widget.isOwnPost
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArtistProfileScreen(
                                userId: widget.post.userId,
                                userName: widget.post.userName,
                                userRole: widget.post.userRole,
                                userLocation: widget.post.userLocation,
                                avatarInitials: widget.post.userName
                                    .split(' ')
                                    .map((n) => n[0])
                                    .take(2)
                                    .join()
                                    .toUpperCase(),
                              ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.post.userRole} · ${widget.post.userLocation}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
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
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
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
                  onPageChanged: (index) => setState(() {
                    _currentMediaIndex = index;
                  }),
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
                                child: Stack(
                                  children: [
                                    VideoPlayer(controller),
                                    Center(
                                      child: IconButton(
                                        icon: Icon(
                                          controller.value.isPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          size: 64,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            controller.value.isPlaying
                                                ? controller.pause()
                                                : controller.play();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const Center(child: CircularProgressIndicator());
                    } else {
                      final audIndex =
                          index -
                          widget.post.imageUrls.length -
                          widget.post.videoUrls.length;
                      final url = widget.post.audioUrls[audIndex];
                      final player = _audioPlayers[url]!;

                      return Card(
                        color: Colors.grey[200],
                        margin: const EdgeInsets.all(24),
                        child: ListTile(
                          leading: const Icon(Icons.audiotrack, size: 40),
                          title: Text(url.split('/').last),
                          trailing: IconButton(
                            icon: Icon(
                              player.playing ? Icons.pause : Icons.play_arrow,
                            ),
                            onPressed: () {
                              if (player.playing) {
                                player.pause();
                              } else {
                                player.play();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 12),
            // Actions: Likes, Comments, Share, Save
            Row(
              children: [
                Text(
                  TimeHelper.getRelativeTime(widget.post.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
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
                  onTap: () => _showCommentsSheet(context),
                  child: BlocBuilder<CommentBloc, CommentState>(
                    builder: (context, state) {
                      int commentCount = 0;
                      if (state is CommentLoaded) {
                        commentCount = state.comments
                            .where((c) => c.postId == widget.post.id)
                            .length;
                      }
                      return Row(
                        children: [
                          const Icon(Icons.comment_outlined, size: 20),
                          const SizedBox(width: 4),
                          Text('$commentCount'),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      context.read<PostBloc>().add(SharePost(widget.post.id)),
                  child: const Icon(Icons.share_outlined, size: 20),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      context.read<PostBloc>().add(ToggleSave(widget.post.id)),
                  child: Icon(
                    widget.post.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: widget.post.isSaved ? Colors.blue : null,
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
