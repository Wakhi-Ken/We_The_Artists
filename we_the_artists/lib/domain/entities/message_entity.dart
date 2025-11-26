import 'package:equatable/equatable.dart';

/// This class represents a message in a chat app.
class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  /// Here we create a message with all the necessary info.
  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  /// Overrides the [props] getter from Equatable to allow for value comparison.
  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    content,
    timestamp,
    isRead,
  ];
}
