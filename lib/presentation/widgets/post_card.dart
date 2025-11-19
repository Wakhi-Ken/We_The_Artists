import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import '../screens/artist_profile_screen.dart';
import '../utils/avatar_gradients.dart';
import '../utils/mention_text_helper.dart';
import '../utils/time_helper.dart';
import '../widgets/animated_gradient_avatar.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final bool isOwnPost;

  const PostCard({
    super.key,
    required this.post,
    this.isOwnPost = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showLikeAnimation = false;

  @override
  void initState() {
    super.initState();
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
        setState(() {
          _showLikeAnimation = false;
        });
        _likeAnimationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!widget.post.isLiked) {
      context.read<PostBloc>().add(ToggleLike(widget.post.id));
    }
    setState(() {
      _showLikeAnimation = true;
    });
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
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
              Expanded(
                child: BlocProvider.value(
                  value: context.read<CommentBloc>(),
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
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
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
            Row(
              children: [
                GestureDetector(
                  onTap: widget.isOwnPost
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArtistProfileScreen(
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
                  child: GestureDetector(
                    onTap: widget.isOwnPost
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistProfileScreen(
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!widget.isOwnPost)
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      bool isFollowing = false;
                      if (state is UserLoaded) {
                        isFollowing = state.followedUsers[widget.post.userId] ?? false;
                      }
                      
                      return OutlinedButton(
                        onPressed: () {
                          context.read<UserBloc>().add(ToggleFollow(widget.post.userId));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isFollowing ? Colors.grey : Colors.blue,
                          backgroundColor: isFollowing ? Colors.grey[200] : Colors.white,
                          side: BorderSide(
                            color: isFollowing ? Colors.grey : Colors.blue,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(isFollowing ? 'Following' : 'Follow'),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
            if (widget.post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
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
            ],
            if (widget.post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/${widget.post.imageUrls[0]}.jpg',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 60, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    // Animated heart overlay on double-tap
                    if (_showLikeAnimation)
                      AnimatedBuilder(
                        animation: _likeAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _likeAnimation.value,
                            child: Opacity(
                              opacity: 1.0 - _likeAnimation.value,
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 120,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  TimeHelper.getRelativeTime(widget.post.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    context.read<PostBloc>().add(ToggleLike(widget.post.id));
                  },
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
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
                  onTap: () {
                    _showCommentsSheet(context);
                  },
                  child: BlocBuilder<CommentBloc, CommentState>(
                    builder: (context, commentState) {
                      int commentCount = 0;
                      if (commentState is CommentLoaded) {
                        commentCount = commentState.comments
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
                  onTap: () {
                    context.read<PostBloc>().add(SharePost(widget.post.id));
                  },
                  child: const Icon(Icons.share_outlined, size: 20),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    context.read<PostBloc>().add(ToggleSave(widget.post.id));
                  },
                  child: Icon(
                    widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
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
