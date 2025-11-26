import 'package:equatable/equatable.dart';

/// Base class for all comment-related events.
abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load comments for a specific post.
class LoadComments extends CommentEvent {
  final String postId;

  const LoadComments(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Event to add a new comment to a specific post.
class AddComment extends CommentEvent {
  final String postId;
  final String content;

  const AddComment({required this.postId, required this.content});

  @override
  List<Object?> get props => [postId, content];
}
