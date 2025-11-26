import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/avatar_gradients.dart';
import '../widgets/animated_gradient_avatar.dart';
import '../screens/artist_profile_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final Map<String, bool> _followStatus = {};

  Future<void> _loadFollowStatus(String userId) async {
    if (currentUser == null || userId == currentUser!.uid) return;

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('following')
        .doc(userId)
        .get();

    setState(() {
      _followStatus[userId] = doc.exists;
    });
  }

  Future<void> _toggleFollow(String userId) async {
    if (currentUser == null || userId == currentUser!.uid) return;

    final followingRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('following')
        .doc(userId);

    final followersRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('followers')
        .doc(currentUser!.uid);

    final isFollowing = _followStatus[userId] ?? false;

    if (isFollowing) {
      await followingRef.delete();
      await followersRef.delete();
    } else {
      await followingRef.set({'followedAt': FieldValue.serverTimestamp()});
      await followersRef.set({'followedAt': FieldValue.serverTimestamp()});
    }

    setState(() {
      _followStatus[userId] = !isFollowing;
    });
  }

  void _goToArtistProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArtistProfileScreen(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Recommended Artists',
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data();
              final userId = users[index].id;
              final name = userData['name'] ?? 'Unknown';
              final role = userData['role'] ?? '';
              final location = userData['location'] ?? '';
              final avatarUrl = userData['avatarUrl'] ?? '';
              final colors = AvatarGradients.getGradientForUser(userId);

              if (!_followStatus.containsKey(userId)) {
                _loadFollowStatus(userId);
              }

              final showFollowButton =
                  currentUser != null && userId != currentUser!.uid;
              final isFollowing = _followStatus[userId] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _goToArtistProfile(userId),
                      child: avatarUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(avatarUrl),
                            )
                          : AnimatedGradientAvatar(
                              initials: name
                                  .split(' ')
                                  .map((n) => n[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                              size: 60,
                              gradientColors: colors,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _goToArtistProfile(userId),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$role · $location',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showFollowButton)
                      ElevatedButton(
                        onPressed: () => _toggleFollow(userId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? Colors.grey[300]
                              : Colors.blue,
                          foregroundColor: isFollowing
                              ? Colors.black
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        child: Text(isFollowing ? 'Following' : 'Follow'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
