import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PostBloc() : super(const PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<ToggleLike>(_onToggleLike);
    on<ToggleSave>(_onToggleSave);
    on<SharePost>(_onSharePost);
    on<OpenComments>(_onOpenComments);
  }

  // Load posts from Firestore with real-time updates
  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .orderBy('createdAt', descending: true)
          .get();

      print("Posts fetched successfully"); // Debugging line

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

      print("Posts loaded: ${posts.length}"); // Debugging line

      emit(PostLoaded(posts)); // Emitting PostLoaded state
    } catch (e) {
      print('Error loading posts: $e'); // Debugging line
      emit(PostError(e.toString()));
    }
  }

  // Toggle like for a post
  Future<void> _onToggleLike(ToggleLike event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          final updatedLikes = post.isLiked ? post.likes - 1 : post.likes + 1;
          _updatePostLikes(post.id, updatedLikes); // Sync with Firestore
          return post.copyWith(isLiked: !post.isLiked, likes: updatedLikes);
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
          _updatePostSaved(post.id, !post.isSaved); // Sync with Firestore
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

  // Update Firestore post's like count
  Future<void> _updatePostLikes(String postId, int newLikes) async {
    try {
      await _firestore.collection('Posts').doc(postId).update({
        'likes': newLikes,
      });
    } catch (e) {
      // Handle errors or logging
    }
  }

  // Update Firestore post's saved state
  Future<void> _updatePostSaved(String postId, bool isSaved) async {
    try {
      await _firestore.collection('Posts').doc(postId).update({
        'isSaved': isSaved,
      });
    } catch (e) {
      // Handle errors or logging
    }
  }
}
