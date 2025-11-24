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

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(event.userId)
          .get();

      final data = doc.data();
      if (data == null) throw Exception('User not found');

      final user = UserEntity(
        id: doc.id,
        name: data['name'] ?? '',
        role: data['role'] ?? '',
        location: data['location'] ?? '',
        bio: data['bio'] ?? '',
        avatarUrl: data['avatarUrl'] ?? '',
        followers: List<String>.from(data['followers'] ?? []),
        following: List<String>.from(data['following'] ?? []),
      );

      // Map of followed users for quick lookup (you can modify as needed)
      final followedUsers = <String, bool>{};
      for (var id in user.following) {
        followedUsers[id] = true;
      }

      emit(UserLoaded(user: user, followedUsers: followedUsers));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      final current = state as UserLoaded;
      final updatedUser = current.user.copyWith(
        name: event.name,
        role: event.role,
        location: event.location,
        bio: event.bio,
      );

      emit(current.copyWith(user: updatedUser));

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .update({
            'name': event.name,
            'role': event.role,
            'location': event.location,
            'bio': event.bio,
          });
    }
  }

  Future<void> _onToggleFollow(
    ToggleFollow event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      final current = state as UserLoaded;
      final updatedUser = current.user;
      final following = List<String>.from(updatedUser.following);

      if (following.contains(event.userId)) {
        following.remove(event.userId);
      } else {
        following.add(event.userId);
      }

      final newUser = updatedUser.copyWith(following: following);

      // Update followedUsers map
      final followedUsers = Map<String, bool>.from(current.followedUsers);
      followedUsers[event.userId] = following.contains(event.userId);

      emit(current.copyWith(user: newUser, followedUsers: followedUsers));

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.id)
          .update({'following': following});
    }
  }
}
