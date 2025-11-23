import 'package:flutter_bloc/flutter_bloc.dart';
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
      LoadUserProfile event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      const user = UserEntity(
        id: '1',
        name: 'Aline Mukarurangwa',
        role: 'Painter',
        location: 'Kigali',
        bio: 'speak my mind through my pen...',
        avatarUrl: '',
      );

      emit(UserLoaded(
        user: user,
        followedUsers: {},
      ));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;

      final updatedUser = UserEntity(
        id: currentState.user.id,
        name: event.name,
        role: event.role,
        location: event.location,
        bio: event.bio,
        avatarUrl: currentState.user.avatarUrl,
      );

      emit(currentState.copyWith(user: updatedUser));
    }
  }

  Future<void> _onToggleFollow(
      ToggleFollow event, Emitter<UserState> emit) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      final updatedFollowedUsers = Map<String, bool>.from(currentState.followedUsers);

      if (updatedFollowedUsers.containsKey(event.userId)) {
        updatedFollowedUsers[event.userId] = !updatedFollowedUsers[event.userId]!;
      } else {
        updatedFollowedUsers[event.userId] = true;
      }

      emit(currentState.copyWith(followedUsers: updatedFollowedUsers));
    }
  }
}
