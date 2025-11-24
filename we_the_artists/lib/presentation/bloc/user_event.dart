import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a specific user's profile
class LoadUserProfile extends UserEvent {
  final String userId; // Added userId field

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to update the current user's profile
class UpdateUserProfile extends UserEvent {
  final String name;
  final String role;
  final String location;
  final String bio;

  const UpdateUserProfile({
    required this.name,
    required this.role,
    required this.location,
    required this.bio,
  });

  @override
  List<Object?> get props => [name, role, location, bio];
}

/// Event to follow/unfollow another user
class ToggleFollow extends UserEvent {
  final String userId;

  const ToggleFollow(this.userId);

  @override
  List<Object?> get props => [userId];
}
