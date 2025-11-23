import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosts extends PostEvent {
  const LoadPosts();
}

class ToggleLike extends PostEvent {
  final String postId;

  const ToggleLike(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ToggleSave extends PostEvent {
  final String postId;

  const ToggleSave(this.postId);

  @override
  List<Object?> get props => [postId];
}

class SharePost extends PostEvent {
  final String postId;

  const SharePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class OpenComments extends PostEvent {
  final String postId;

  const OpenComments(this.postId);

  @override
  List<Object?> get props => [postId];
}
