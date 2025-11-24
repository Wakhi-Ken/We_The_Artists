import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String userLocation;
  final String userAvatarUrl;
  final String content;
  final List<String> imageUrls;
  final List<String> videoUrls; // added
  final List<String> audioUrls; // added
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userLocation,
    required this.userAvatarUrl,
    required this.content,
    this.imageUrls = const [],
    this.videoUrls = const [],
    this.audioUrls = const [],
    this.tags = const [],
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? userLocation,
    String? userAvatarUrl,
    String? content,
    List<String>? imageUrls,
    List<String>? videoUrls,
    List<String>? audioUrls,
    List<String>? tags,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userLocation: userLocation ?? this.userLocation,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      audioUrls: audioUrls ?? this.audioUrls,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userRole,
    userLocation,
    userAvatarUrl,
    content,
    imageUrls,
    videoUrls,
    audioUrls,
    tags,
    likes,
    comments,
    isLiked,
    isSaved,
    createdAt,
  ];
}
