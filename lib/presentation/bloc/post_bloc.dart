import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final posts = _getMockPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

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

  Future<void> _onSharePost(SharePost event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final post = currentState.posts.firstWhere((p) => p.id == event.postId);
      
      await Share.share(
        '${post.content}\n\n- ${post.userName}',
        subject: 'Check out this artwork!',
      );
    }
  }

  Future<void> _onOpenComments(
      OpenComments event, Emitter<PostState> emit) async {
    // placeholder for comment functionality
  }

  List<PostEntity> _getMockPosts() {
    return [
      PostEntity(
        id: '1',
        userId: '2',
        userName: 'Sarah Johnson',
        userRole: 'Digital Artist',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content:
            'Just finished this cyberpunk cityscape! What do you think? Open to feedback on the color palette.',
        imageUrls: ['assets/images/painting_couple_rainy_night.png'],
        tags: ['digital', 'cyberpunk'],
        likes: 342,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      PostEntity(
        id: '2',
        userId: '2',
        userName: 'Sarah Johnson',
        userRole: 'Digital Artist',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Experimenting with abstract forms today. @AlineMukarurangwa would love your thoughts on this!',
        imageUrls: ['assets/images/painting_abstract_colors.png'],
        tags: ['abstract', 'digitalart'],
        likes: 198,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      PostEntity(
        id: '3',
        userId: '3',
        userName: 'David Kamau',
        userRole: 'Sculptor',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Working with clay today. The texture is amazing!',
        imageUrls: ['assets/images/african_woman_portrait.png'],
        tags: ['sculpture', 'clay'],
        likes: 128,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      PostEntity(
        id: '4',
        userId: '3',
        userName: 'David Kamau',
        userRole: 'Sculptor',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'New bronze sculpture completed! Thanks @EmmaWilliams for capturing the perfect angles.',
        imageUrls: ['assets/images/Screenshot 2025-11-17 at 13.26.57.png'],
        tags: ['bronze', 'sculpture'],
        likes: 245,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      PostEntity(
        id: '5',
        userId: '1',
        userName: 'Aline Mukarurangwa',
        userRole: 'Visual Artist',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content:
            'Working on a new textile piece that explores migration. Looking for composition feedback — comments welcome!',
        imageUrls: ['assets/images/Screenshot 2025-11-17 at 13.33.03.png'],
        tags: ['critique', 'textile'],
        likes: 24,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      PostEntity(
        id: '6',
        userId: '4',
        userName: 'Emma Williams',
        userRole: 'Photographer',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Golden hour magic at Lake Kivu. Nature is the best artist.',
        imageUrls: ['assets/images/Screenshot 2025-11-17 at 13.33.29.png'],
        tags: ['photography', 'nature'],
        likes: 567,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      PostEntity(
        id: '7',
        userId: '4',
        userName: 'Emma Williams',
        userRole: 'Photographer',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Portrait session with @DavidKamau. Capturing artists at work is my favorite!',
        imageUrls: ['assets/images/birds_sunset.png'],
        tags: ['portrait', 'artistlife'],
        likes: 423,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PostEntity(
        id: '8',
        userId: '1',
        userName: 'Aline Mukarurangwa',
        userRole: 'Painter',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Enjoyed painting this work last week!',
        imageUrls: ['assets/images/Screenshot 2025-11-17 at 13.40.44.png'],
        tags: [],
        likes: 156,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PostEntity(
        id: '9',
        userId: '5',
        userName: 'Michael Odhiambo',
        userRole: 'Illustrator',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Vibrant portrait study with bold colors. Love exploring different color palettes!',
        imageUrls: ['assets/images/Screenshot 2025-11-19 at 19.26.05.png'],
        tags: ['illustration', 'portrait', 'colorful'],
        likes: 289,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PostEntity(
        id: '10',
        userId: '5',
        userName: 'Michael Odhiambo',
        userRole: 'Illustrator',
        userLocation: 'Kigali',
        userAvatarUrl: '',
        content: 'Wildlife series - zebra on canvas. Inspired by African wildlife! @AlineMukarurangwa check this out.',
        imageUrls: ['assets/images/Screenshot 2025-11-19 at 19.26.18.png'],
        tags: ['wildlife', 'painting', 'zebra'],
        likes: 412,
        comments: 0,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}
