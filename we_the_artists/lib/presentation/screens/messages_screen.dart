import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/avatar_gradients.dart';
import '../widgets/animated_gradient_avatar.dart';
import '../widgets/post_card.dart';
import '../../domain/entities/post_entity.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  /// Fetch all users once to avoid unknown usernames
  Future<Map<String, String>> _fetchUserNames() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .get();
    final Map<String, String> userMap = {};
    for (var doc in userSnapshot.docs) {
      final data = doc.data();
      userMap[doc.id] = data['name'] ?? 'Unknown';
    }
    return userMap;
  }

  /// Fetch all comments across posts of current user
  Future<List<Map<String, dynamic>>> _fetchComments(
    String currentUserId,
  ) async {
    final userMap = await _fetchUserNames();
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('Posts')
        .where('userId', isEqualTo: currentUserId)
        .get();

    final List<Map<String, dynamic>> comments = [];

    for (var postDoc in postsSnapshot.docs) {
      final postId = postDoc.id;
      final commentSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      for (var c in commentSnapshot.docs) {
        final data = c.data();
        final senderId = data['userId'] ?? '';
        final senderName = userMap[senderId] ?? 'Unknown';

        comments.add({
          'postId': postId,
          'commentId': c.id,
          'content': data['text'] ?? '',
          'senderId': senderId,
          'senderName': senderName,
          'timestamp':
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        });
      }
    }

    comments.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return comments;
  }

  /// Open a specific post using PostCard
  void _openPost(BuildContext context, String postId) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Post')),
          body: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Posts')
                .doc(postId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Post not found.'));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final post = PostEntity.fromFirestore(
                data,
                snapshot.data!.id,
                currentUserId,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: PostCard(
                  post: post,
                  isOwnPost: post.userId == currentUserId,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comments & Messages',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchComments(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No comments yet.'));
          }

          final comments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final colors = AvatarGradients.getGradientForUser(
                comment['senderId'],
              );

              return ListTile(
                leading: AnimatedGradientAvatar(
                  initials: comment['senderName']
                      .split(' ')
                      .map((n) => n[0])
                      .take(2)
                      .join()
                      .toUpperCase(),
                  size: 50,
                  gradientColors: colors,
                ),
                title: Text(
                  comment['senderName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                subtitle: Text(
                  comment['content'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Text(
                  _formatTime(comment['timestamp']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                onTap: () => _openPost(context, comment['postId']),
              );
            },
          );
        },
      ),
    );
  }
}
