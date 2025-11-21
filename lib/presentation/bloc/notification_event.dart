import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}

class AddMentionNotification extends NotificationEvent {
  final String mentionerUserId;
  final String mentionerUserName;

  const AddMentionNotification({
    required this.mentionerUserId,
    required this.mentionerUserName,
  });

  @override
  List<Object?> get props => [mentionerUserId, mentionerUserName];
}
