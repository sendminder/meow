import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meow/chat_room.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'websocket_provider.dart';

class ChatRoomListScreen extends StatefulWidget {
  final int userId;

  ChatRoomListScreen({required this.userId});

  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  List<ChatRoom> chatRooms = [];

  @override
  void initState() {
    super.initState();
    fetchChatRooms();
  }

  Future<void> fetchChatRooms() async {
    final response = await http.get(
        Uri.parse('http://localhost:8000/user_conversations/${widget.userId}'));

    if (response.statusCode == 200) {
      final parsedResponse = json.decode(response.body);
      final conversations = parsedResponse['conversations'];

      List<ChatRoom> rooms = conversations
          .map<ChatRoom>((item) => ChatRoom.fromJson(item))
          .toList();

      setState(() {
        chatRooms = rooms;
      });
    } else {
      print('Failed to fetch chat rooms');
    }
  }

  Future<void> _createChatRoom() async {
    final createConversationData = {
      'name': 'New Chat Room', // 이름 설정 (필요에 따라 변경)
      'host_user_id': widget.userId,
      'joined_users': [widget.userId, 8], // 호스트 유저 포함
    };

    final response = await http.post(
      Uri.parse('http://localhost:8000/conversations'),
      body: json.encode(createConversationData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // 채팅방 생성 성공 시 처리할 로직
      print('Chat room created successfully');
      // 채팅방 목록을 다시 불러오는 메서드 호출
      fetchChatRooms();
    } else {
      // 채팅방 생성 실패 시 처리할 로직
      print('Failed to create chat room');
    }
  }

  void _enterChatRoom(int chatRoomId, String ctype) {
    final webSocketProvider =
        Provider.of<WebSocketProvider>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: webSocketProvider,
          child: ChatRoomScreen(
              chatRoomId: chatRoomId, chatType: ctype, userId: widget.userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Chat Room List')),
        body: ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(chatRooms[index].name),
            onTap: () =>
                _enterChatRoom(chatRooms[index].id, chatRooms[index].type),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 채팅방 생성 버튼을 눌렀을 때 동작하는 코드 추가
            _createChatRoom();
          },
          child: Icon(Icons.add),
        ),
      );
}

class ChatRoom {
  final String name;
  final int id;
  final String type;

  ChatRoom({required this.name, required this.id, required this.type});

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      name: json['name'],
      id: json['id'],
      type: json['type'],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChatRoomListScreen(userId: 8), // 사용자 ID를 전달
  ));
}
