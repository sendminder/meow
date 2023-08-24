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
              itemBuilder: (context, index) {
                final message =
                    _webSocketProvider.getMessages(widget.chatRoomId)[index];
                final isMyMessage = message.senderId == widget.userId;

                final messageTextStyle = const TextStyle(
                  fontFamily: 'NotoSans',
                  color: Colors.black,
                  fontSize: 16.0,
                );
                final timeTextStyle = const TextStyle(
                  color: Color.fromARGB(228, 172, 172, 172),
                  fontSize: 10.0,
                );

                final textWidth = TextPainter(
                  text:
                      TextSpan(text: message.content, style: messageTextStyle),
                  textDirection: TextDirection.ltr,
                )..layout();

                final timeWidget = Text(
                  message.formattedCreatedAt,
                  style: timeTextStyle,
                );

                final bgColor = isMyMessage
                    ? Color.fromARGB(150, 118, 182, 234)
                    : Color.fromARGB(150, 129, 218, 132);

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: isMyMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (isMyMessage) timeWidget,
                      Container(
                        margin: EdgeInsets.only(left: 8.0, right: 6.0),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 1.0,
                          ),
                        ),
                        width: textWidth.width + 30.0,
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: messageTextStyle,
                            ),
                          ],
                        ),
                      ),
                      if (!isMyMessage) timeWidget,
                    ],
                  ),
                );
              },
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
