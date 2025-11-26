import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.content,
    required this.createdAt,
  });

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
