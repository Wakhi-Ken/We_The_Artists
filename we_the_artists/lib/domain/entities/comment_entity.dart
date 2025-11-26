import 'package:equatable/equatable.dart';

/// Represents a comment on a post.
class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String content;
  final DateTime createdAt;

  /// Constructor for creating a CommentEntity.
  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  /// This allows for easy equality checking between instances.
  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    userName,
    userAvatarUrl,
    content,
    createdAt,
  ];
}
