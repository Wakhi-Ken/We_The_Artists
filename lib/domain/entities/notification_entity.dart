import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        userId,
        userName,
        message,
        createdAt,
        isRead,
      ];
}
