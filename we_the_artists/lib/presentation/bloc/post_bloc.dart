import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/post_entity.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final List<PostEntity> initialPosts;

  PostBloc({this.initialPosts = const []}) : super(const PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<ToggleLike>(_onToggleLike);
    on<ToggleSave>(_onToggleSave);
    on<SharePost>(_onSharePost);
    on<OpenComments>(_onOpenComments);
  }

  // Load posts (from API or local DB)
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    try {
      // Replace this with actual API call
      final posts = initialPosts;
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  // Toggle like for a post
  Future<void> _onToggleLike(ToggleLike event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likes: post.isLiked ? post.likes - 1 : post.likes + 1,
          );
        }
        return post;
      }).toList();

      emit(PostLoaded(updatedPosts));
    }
  }

  // Toggle save for a post
  Future<void> _onToggleSave(ToggleSave event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(isSaved: !post.isSaved);
        }
        return post;
      }).toList();

      emit(PostLoaded(updatedPosts));
    }
  }

  // Share a post
  Future<void> _onSharePost(SharePost event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      try {
        final post = currentState.posts.firstWhere((p) => p.id == event.postId);
        await Share.share(
          '${post.content}\n\n- ${post.userName}',
          subject: 'Check out this artwork!',
        );
      } catch (e) {
        // Optionally emit error state or log
      }
    }
  }

  // Placeholder for comments, actual logic handled in CommentBloc
  Future<void> _onOpenComments(
    OpenComments event,
    Emitter<PostState> emit,
  ) async {}
}
