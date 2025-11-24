import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ToggleFollow>(_onToggleFollow);
  }

  /// Load user profile from Firestore
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.userId)
          .get();

      if (!doc.exists) {
        emit(UserError('User not found'));
        return;
      }

      final data = doc.data()!;
      final user = UserEntity(
        id: doc.id,
        name: data['name'] ?? '',
        role: data['role'] ?? '',
        location: data['location'] ?? '',
        bio: data['bio'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
      );

      // Optionally, fetch followed users from Firestore if you store them
      final followedUsersData =
          data['followedUsers'] as Map<String, dynamic>? ?? {};
      final followedUsers = followedUsersData.map(
        (key, value) => MapEntry(key, value as bool),
      );

      emit(UserLoaded(user: user, followedUsers: followedUsers));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Update user profile in Firestore
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) return;
    final currentState = state as UserLoaded;

    final updatedUser = UserEntity(
      id: currentState.user.id,
      name: event.name,
      role: event.role,
      location: event.location,
      bio: event.bio,
      avatarUrl: currentState.user.avatarUrl,
    );

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(updatedUser.id)
          .update({
            'name': updatedUser.name,
            'role': updatedUser.role,
            'location': updatedUser.location,
            'bio': updatedUser.bio,
          });

      emit(currentState.copyWith(user: updatedUser));
    } catch (e) {
      emit(UserError('Failed to update profile: $e'));
    }
  }

  /// Toggle follow/unfollow a user
  Future<void> _onToggleFollow(
    ToggleFollow event,
    Emitter<UserState> emit,
  ) async {
    if (state is! UserLoaded) return;
    final currentState = state as UserLoaded;
    final updatedFollowedUsers = Map<String, bool>.from(
      currentState.followedUsers,
    );

    updatedFollowedUsers[event.userId] =
        !(updatedFollowedUsers[event.userId] ?? false);

    // Optionally, update Firestore to persist following
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentState.user.id)
          .update({'followedUsers': updatedFollowedUsers});
    } catch (e) {
      print('Failed to update followed users: $e');
    }

    emit(currentState.copyWith(followedUsers: updatedFollowedUsers));
  }
}
