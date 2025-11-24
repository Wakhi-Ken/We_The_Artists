import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(const PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<ToggleLike>(_onToggleLike);
    on<ToggleSave>(_onToggleSave);
    on<SharePost>(_onSharePost);
    on<OpenComments>(_onOpenComments);
  }

  // Load posts from Firestore
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        return PostEntity(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['displayName'] ?? 'Unknown',
          userRole: data['userRole'] ?? '',
          userLocation: data['userLocation'] ?? '',
          userAvatarUrl: data['avatarUrl'] ?? '',
          content: data['content'] ?? '',
          imageUrls: data['imageUrls'] != null
              ? List<String>.from(data['imageUrls'])
              : [],
          videoUrls: data['videoUrls'] != null
              ? List<String>.from(data['videoUrls'])
              : [],
          audioUrls: data['audioUrls'] != null
              ? List<String>.from(data['audioUrls'])
              : [],
          tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          isLiked: false,
          isSaved: false,
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

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

  // Placeholder for comments, handled by CommentBloc
  Future<void> _onOpenComments(
    OpenComments event,
    Emitter<PostState> emit,
  ) async {}
}
