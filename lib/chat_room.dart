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
  dynamic _webSocketProvider;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  void dispose() {
    super.dispose();
    _webSocketProvider.removeListener(handleEvent);
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
        _webSocketProvider.setMessages(widget.chatRoomId, messageObjects);
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      print('Failed to fetch messages');
    }
  }

  Future<void> sendMessage() async {
    _webSocketProvider.sendMessage(
        _messageController.text, widget.chatRoomId, widget.userId);
    _messageController.clear();
    setState(() {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void handleEvent() {
    setState(() {
      print('event handle!');
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    _webSocketProvider = Provider.of<WebSocketProvider>(context, listen: true);
    _webSocketProvider.addListener(handleEvent);

    return Scaffold(
      appBar: AppBar(title: Text('Chat Room #${widget.chatRoomId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  _webSocketProvider.getMessages(widget.chatRoomId).length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_webSocketProvider
                    .getMessages(widget.chatRoomId)[index]
                    .content),
                subtitle: Text(_webSocketProvider
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
