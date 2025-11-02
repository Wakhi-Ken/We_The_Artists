import 'package:flutter/material.dart';

class Post {
  final String name;
  final String role;
  final String location;
  final String content;
  final String? imageUrl;
  final String? audioUrl;
  final List<String> tags;

  const Post({
    required this.name,
    required this.role,
    required this.location,
    required this.content,
    this.imageUrl,
    this.audioUrl,
    required this.tags,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Sample post list
  final List<Post> posts = const [
    Post(
      name: 'Aline Mukarurangwa',
      role: 'Visual Artist',
      location: 'Kigali',
      content: 'This is a sample post content.',
      imageUrl: null,
      audioUrl: null,
      tags: ['Art', 'Music'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(radius: 30, child: Text('AM')),
                  SizedBox(height: 10),
                  Text(
                    'Aline Mukarurangwa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Visual Artist • Kigali',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              post.name.isNotEmpty ? post.name[0] : '?',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.name.isNotEmpty ? post.name : 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (post.role.isNotEmpty ||
                                  post.location.isNotEmpty)
                                Text(
                                  '${post.role} • ${post.location}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder for follow action
                        },
                        child: const Text('Follow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Post content
                  if (post.content.isNotEmpty) Text(post.content),
                  const SizedBox(height: 8),
                  if (post.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(post.imageUrl!),
                    ),
                  if (post.audioUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: const [
                          Icon(Icons.audiotrack),
                          SizedBox(width: 8),
                          Text('Audio placeholder'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Tags
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: post.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 8),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Icon(Icons.favorite_border),
                      Icon(Icons.comment),
                      Icon(Icons.share),
                      Icon(Icons.bookmark_border),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Floating Action Button pressed'); // Debugging
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
