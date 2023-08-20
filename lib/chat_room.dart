import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meow/chat_room.dart';
import 'package:http/http.dart' as http;

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;

  ChatRoomScreen({required this.chatRoomId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:8000/conversations/${widget.chatRoomId}/messages'),
    );

    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      final messageList = parsedResponse['messages'];

      List<Message> messageObjects =
          messageList.map<Message>((item) => Message.fromJson(item)).toList();

      setState(() {
        messages = messageObjects;
      });
    } else {
      print('Failed to fetch messages');
    }
  }

  Future<void> sendMessage() async {
    // final newMessage = _messageController.text;
    // if (newMessage.isNotEmpty) {
    //   final createMessageData = {
    //     'content': newMessage,
    //     'user_id': widget.chatRoomId, // 사용자 ID 전달 (혹은 필요한 값)
    //   };

    //   final response = await http.post(
    //     Uri.parse(
    //         'http://localhost:8000/conversations/${widget.chatRoomId}/messages'),
    //     body: json.encode(createMessageData),
    //     headers: {'Content-Type': 'application/json'},
    //   );

    //   if (response.statusCode == 201) {
    //     // 메시지 생성 성공 시 처리할 로직
    //     print('Message sent successfully');
    //     _messageController.clear(); // 메시지 입력창 초기화
    //     fetchMessages(); // 메시지 목록 업데이트
    //   } else {
    //     // 메시지 생성 실패 시 처리할 로직
    //     print('Failed to send message');
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Room #${widget.chatRoomId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index].content),
                  subtitle: Text(messages[index].createdAt.toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String content;
  final DateTime createdAt;

  Message({required this.content, required this.createdAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['text'],
      createdAt: DateTime.parse(json['CreatedTime']),
    );
  }
}
