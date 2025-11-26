// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/post_card.dart';

class ArtistProfileScreen extends StatelessWidget {
  final String userId;

  const ArtistProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => UserBloc()..add(LoadUserProfile(userId)),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              theme.appBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Artist Profile',
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color ?? Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            if (userState is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (userState is UserError) {
              return Center(child: Text('Error: ${userState.message}'));
            } else if (userState is UserLoaded) {
              final user = userState.user;
              final avatarInitials = user.name
                  .split(' ')
                  .map((n) => n[0])
                  .take(2)
                  .join()
                  .toUpperCase();

              return Column(
                children: [
                  Container(
                    color: theme.cardColor,
                    child: ProfileHeader(
                      name: user.name,
                      role: user.role,
                      location: user.location,
                      bio: user.bio,
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
                            return Center(
                              child: Text(
                                'No posts yet',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: userPosts.length,
                            itemBuilder: (context, index) {
                              return PostCard(
                                post: userPosts[index],
                                isOwnPost: false,
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
