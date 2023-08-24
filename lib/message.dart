import 'package:intl/intl.dart';

class Message {
  final String content;
  final DateTime createdAt;
  final int id;
  final int convId;
  final int senderId;

  Message(
      {required this.content,
      required this.createdAt,
      required this.id,
      required this.convId,
      required this.senderId}) {}

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        content: json['text'],
        createdAt: DateTime.parse(json['created_time']),
        id: json['id'],
        convId: json['conversation_id'],
        senderId: json['sender_id'],
      );

  String get formattedCreatedAt {
    final formattedTime = DateFormat('HH:mm').format(createdAt.toLocal());
    return formattedTime;
  }
}
