import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/post_card.dart';
import '../widgets/theme_switcher.dart';

import 'notifications_screen.dart';
import 'messages_screen.dart';
import 'package:we_the_artists/screens/community_screen.dart';
import 'package:we_the_artists/screens/wellness_screen.dart';
import 'my_account_screen.dart';
import 'create_post_screen_v2.dart';

import '../../domain/entities/post_entity.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeFeedContent(),
    const CommunityScreen(),
    WellnessScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Artist Feed'
              : _currentIndex == 1
              ? 'Community'
              : 'Wellness',
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: _currentIndex == 0
            ? [
                const ThemeSwitcher(),
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.message_outlined,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MessagesScreen()),
                    );
                  },
                ),
              ]
            : null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'We The Artists',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyAccountScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chats'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/event');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signup',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Wellness',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            )
          : null,
    );
  }
}

/// -----------------
/// Feed Content
/// -----------------
class HomeFeedContent extends StatelessWidget {
  const HomeFeedContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }

        final posts = snapshot.data!.docs;

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postDoc = posts[index];
              final postData = postDoc.data()! as Map<String, dynamic>;

              // Extract media safely
              final List<String> imageUrls = postData['imageUrls'] != null
                  ? List<String>.from(postData['imageUrls'])
                  : [];
              final List<String> videoUrls = postData['videoUrls'] != null
                  ? List<String>.from(postData['videoUrls'])
                  : [];
              final List<String> audioUrls = postData['audioUrls'] != null
                  ? List<String>.from(postData['audioUrls'])
                  : [];

              final post = PostEntity(
                id: postDoc.id,
                userId: postData['userId'] ?? '',
                userName: postData['displayName'] ?? 'Unknown',
                userRole: postData['userRole'] ?? '',
                userLocation: postData['userLocation'] ?? '',
                userAvatarUrl: postData['userAvatarUrl'] ?? '',
                content: postData['content'] ?? '',
                tags: List<String>.from(postData['tags'] ?? []),
                imageUrls: imageUrls,
                videoUrls: videoUrls,
                audioUrls: audioUrls,
                likes: postData['likes'] ?? 0,
                isLiked: postData['isLiked'] ?? false,
                isSaved: postData['isSaved'] ?? false,
                createdAt: postData['createdAt'] != null
                    ? (postData['createdAt'] as Timestamp).toDate()
                    : DateTime.now(),
                comments: postData['comments'] != null
                    ? (postData['comments'] as List).length
                    : 0,
              );

              return PostCard(
                post: post,
                isOwnPost: post.userId == currentUserId,
              );
            },
          ),
        );
      },
    );
  }
}
