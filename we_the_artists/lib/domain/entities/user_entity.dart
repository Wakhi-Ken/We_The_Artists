import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String location;
  final String bio;
  final String avatarUrl;
  final List<String> followers; // Added
  final List<String> following; // Added

  const UserEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.bio,
    required this.avatarUrl,
    this.followers = const [],
    this.following = const [],
  });

  UserEntity copyWith({
    String? name,
    String? role,
    String? location,
    String? bio,
    String? avatarUrl,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    location,
    bio,
    avatarUrl,
    followers,
    following,
  ];
}
