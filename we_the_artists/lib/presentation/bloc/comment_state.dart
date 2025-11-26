import 'package:equatable/equatable.dart';
import '../../domain/entities/comment_entity.dart';

/// Base class for all comment-related states.
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

/// Initial state when comments have not been loaded yet.
class CommentInitial extends CommentState {
  const CommentInitial();
}

/// State that indicates comments are currently being loaded.
class CommentLoading extends CommentState {
  const CommentLoading();
}

class CommentLoaded extends CommentState {
  final List<CommentEntity> comments;

  const CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

///indicates there was an error loading comments.
class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}
