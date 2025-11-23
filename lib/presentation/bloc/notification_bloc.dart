import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final List<NotificationEntity> _notifications = [];

  NotificationBloc() : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<ClearAllNotifications>(_onClearAll);
    on<AddMentionNotification>(_onAddMentionNotification);
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final mockNotifications = _getMockNotifications();
      // Combine mock notifications with real mention notifications
      final allNotifications = [...mockNotifications, ..._notifications];
      // Sort by createdAt descending
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(NotificationLoaded(allNotifications));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<NotificationState> emit) async {
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
      ClearAllNotifications event, Emitter<NotificationState> emit) async {
    _notifications.clear();
    emit(const NotificationLoaded([]));
  }

  Future<void> _onAddMentionNotification(
      AddMentionNotification event, Emitter<NotificationState> emit) async {
    final newNotification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'mention',
      userId: event.mentionerUserId,
      userName: event.mentionerUserName,
      message: 'mentioned you in a post',
      createdAt: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, newNotification);

    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updated = [newNotification, ...currentState.notifications];
      emit(NotificationLoaded(updated));
    }
  }

  List<NotificationEntity> _getMockNotifications() {
    return [
      NotificationEntity(
        id: '1',
        type: 'like',
        userId: '2',
        userName: 'Sarah Johnson',
        message: 'liked your post',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      NotificationEntity(
        id: '2',
        type: 'comment',
        userId: '3',
        userName: 'David Kamau',
        message: 'commented on your post',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationEntity(
        id: '3',
        type: 'follow',
        userId: '4',
        userName: 'Emma Williams',
        message: 'started following you',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationEntity(
        id: '4',
        type: 'mention',
        userId: '2',
        userName: 'Sarah Johnson',
        message: 'mentioned you in a post',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
      ),
    ];
  }
}
