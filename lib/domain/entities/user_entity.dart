import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String location;
  final String bio;
  final String avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.bio,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, role, location, bio, avatarUrl];
}
