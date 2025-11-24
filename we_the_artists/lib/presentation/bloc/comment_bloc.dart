import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment_entity.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final Map<String, List<CommentEntity>> _commentsCache = {};

  // Variables to store user info
  late final String currentUserId;
  late final String currentUserName;
  late final String currentUserAvatarUrl;

  CommentBloc() : super(const CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<CommentInitialize>(
      _onInitialize,
    ); // Add an event to initialize user data
  }

  // Event to initialize user data
  Future<void> _onInitialize(
    CommentInitialize event,
    Emitter<CommentState> emit,
  ) async {
    currentUserId = event.currentUserId;
    currentUserName = event.currentUserName;
    currentUserAvatarUrl = event.currentUserAvatarUrl;
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final comments = _commentsCache[event.postId] ?? [];
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<CommentState> emit,
  ) async {
    if (state is CommentLoaded) {
      final currentComments = (state as CommentLoaded).comments;

      final newComment = CommentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: event.postId,
        userId: currentUserId,
        userName: currentUserName,
        userAvatarUrl: currentUserAvatarUrl,
        content: event.content,
        createdAt: DateTime.now(),
      );

      final updatedComments = [...currentComments, newComment];
      _commentsCache[event.postId] = updatedComments;

      emit(CommentLoaded(updatedComments));
    }
  }
}

// Event for initializing CommentBloc with user data
class CommentInitialize extends CommentEvent {
  final String currentUserId;
  final String currentUserName;
  final String currentUserAvatarUrl;

  const CommentInitialize({
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatarUrl,
  });
}
