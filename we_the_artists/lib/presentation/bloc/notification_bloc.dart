import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// This class manages the state and events related to notifications.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<ClearAllNotifications>(_onClearAll);
  }
  // Firestore instance to interact with the database.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Handles loading notifications when a LoadNotifications event is triggered.
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    try {
      // Fetch all posts
      final snapshot = await _firestore.collection('Posts').get();
      final posts = snapshot.docs;

      List<NotificationEntity> notifications = [];

      for (var postDoc in posts) {
        final post = postDoc.data();
        final postId = postDoc.id;
        final postOwnerId = post['userId'];

        // Only notifications for the current user
        if (postOwnerId == _currentUserId) {
          // Likes
          if (post['likes'] != null) {
            for (var likerId in List<String>.from(post['likes'])) {
              if (likerId != _currentUserId) {
                notifications.add(
                  NotificationEntity(
                    id: 'like_${postId}_$likerId',
                    type: 'like',
                    userId: likerId,
                    userName:
                        '', // you can fetch username from Users collection
                    message: 'liked your post',
                    createdAt: post['createdAt']?.toDate() ?? DateTime.now(),
                    isRead: false,
                  ),
                );
              }
            }
          }

          // Comments
          final commentsSnapshot = await _firestore
              .collection('Posts')
              .doc(postId)
              .collection('Comments')
              .get();
          for (var commentDoc in commentsSnapshot.docs) {
            final comment = commentDoc.data();
            final commenterId = comment['userId'];
            if (commenterId != _currentUserId) {
              notifications.add(
                NotificationEntity(
                  id: 'comment_${commentDoc.id}',
                  type: 'comment',
                  userId: commenterId,
                  userName:
                      '', // fetch username from Users collection if needed
                  message: 'commented on your post',
                  createdAt: comment['createdAt']?.toDate() ?? DateTime.now(),
                  isRead: false,
                ),
              );
            }
          }
        }
      }

      // Sort by newest first
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updated = currentState.notifications.map((n) {
        if (n.id == event.notificationId) {
          return NotificationEntity(
            id: n.id,
            type: n.type,
            userId: n.userId,
            userName: n.userName,
            message: n.message,
            createdAt: n.createdAt,
            isRead: true,
          );
        }
        return n;
      }).toList();

      emit(NotificationLoaded(updated));
    }
  }

  Future<void> _onClearAll(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final cleared = currentState.notifications.map((n) {
        return NotificationEntity(
          id: n.id,
          type: n.type,
          userId: n.userId,
          userName: n.userName,
          message: n.message,
          createdAt: n.createdAt,
          isRead: true,
        );
      }).toList();
      emit(NotificationLoaded(cleared));
    }
  }
}
