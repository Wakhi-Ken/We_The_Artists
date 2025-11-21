import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final UserEntity user;
  final Map<String, bool> followedUsers;

  const UserLoaded({
    required this.user,
    required this.followedUsers,
  });

  UserLoaded copyWith({
    UserEntity? user,
    Map<String, bool>? followedUsers,
  }) {
    return UserLoaded(
      user: user ?? this.user,
      followedUsers: followedUsers ?? this.followedUsers,
    );
  }

  @override
  List<Object?> get props => [user, followedUsers];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
