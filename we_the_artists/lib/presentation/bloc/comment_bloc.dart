import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment_entity.dart';
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final Map<String, List<CommentEntity>> _commentsCache = {};

  CommentBloc() : super(const CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
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
        userId: '1',
        userName: 'Aline Mukarurangwa',
        userAvatarUrl: '',
        content: event.content,
        createdAt: DateTime.now(),
      );

      final updatedComments = [...currentComments, newComment];
      _commentsCache[event.postId] = updatedComments;

      emit(CommentLoaded(updatedComments));
    }
  }
}
