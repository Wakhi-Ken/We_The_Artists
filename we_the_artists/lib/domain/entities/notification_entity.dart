import 'package:equatable/equatable.dart';

/// This class represents a notification in the application.
class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  /// Constructor to create a NotificationEntity with all the required fields.
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  ///method allows comparison between notifications to check for equality.
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
