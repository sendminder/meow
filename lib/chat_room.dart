import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'message.dart';
import 'websocket_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final int chatRoomId;
  final int userId;

  ChatRoomScreen({required this.chatRoomId, required this.userId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  dynamic webSocketProvider;

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
        webSocketProvider.setMessages(widget.chatRoomId, messageObjects);
      });
    } else {
      print('Failed to fetch messages');
    }
  }

  Future<void> sendMessage() async {
    webSocketProvider.sendMessage(
        _messageController.text, widget.chatRoomId, widget.userId);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    webSocketProvider = Provider.of<WebSocketProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: Text('Chat Room #${widget.chatRoomId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount:
                  webSocketProvider.getMessages(widget.chatRoomId).length,
              itemBuilder: (context, index) => ListTile(
                title: Text(webSocketProvider
                    .getMessages(widget.chatRoomId)[index]
                    .content),
                subtitle: Text(webSocketProvider
                    .getMessages(widget.chatRoomId)[index]
                    .createdAt
                    .toString()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
