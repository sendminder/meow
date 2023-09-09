import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'message.dart';

class WebSocketProvider with ChangeNotifier {
  Map<int, List<Message>> messages = {};

  WebSocketChannel? _channel;
  WebSocketProvider(String url) {
    print('WebSocket Connected!');
    _channel = IOWebSocketChannel.connect(url);
    _channel!.stream.listen((event) {
      final decoded = json.decode(event);
      final eventName = decoded['event'];
      print('event = $eventName');
      if (decoded['event'] == 'message') {
        final payload = decoded['payload'];
        final message = payload['message'];
        addMessage(message);
      } else {
        print('Invalid event format: $event');
      }
    });
  }

  WebSocketChannel get channel => _channel!;

  void addMessage(Map<String, dynamic> message) {
    print(message);

    final msg = Message(
      content: message['text'],
      createdAt: DateTime.parse(message['created_time']),
      id: message['id'],
      convId: message['conversation_id'],
      senderId: message['sender_id'],
    );
    appendMessages(message['conversation_id'], msg);

    notifyListeners();
  }

  void sendMessage(
    String message,
    int chatRoomId,
    String chatType,
    int userId,
  ) {
    final payload = {
      'event': 'create_message',
      'payload': {
        'conversation_id': chatRoomId,
        'conversation_type': chatType,
        'text': message,
        'sender_id': userId,
      },
    };
    _channel!.sink.add(json.encode(payload));

    notifyListeners();
  }

  void closeConnection() {
    _channel?.sink.close();
    _channel = null;
  }

  void setMessages(int chatRoomId, List<Message> msgs) {
    messages[chatRoomId] = msgs;
  }

  void appendMessages(int chatRoomId, Message msgs) {
    messages[chatRoomId]?.add(msgs);
  }

  List<Message> getMessages(int chatRoomId) {
    if (!messages.containsKey(chatRoomId)) return <Message>[];
    return messages[chatRoomId]!;
  }
}
