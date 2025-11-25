import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/post_card.dart';

class ArtistProfileScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String userRole;
  final String userLocation;
  final String avatarInitials;

  const ArtistProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userLocation,
    required this.avatarInitials,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: ProfileHeader(
              name: userName,
              role: userRole,
              location: userLocation,
              bio: 'Creating art that speaks to the soul...',
              avatarInitials: avatarInitials,
              onEditProfile: null,
            ),
          ),
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoaded) {
                  final userPosts = state.posts
                      .where((post) => post.userId == userId)
                      .toList();

                  if (userPosts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No posts yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: userPosts[index], isOwnPost: false);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
