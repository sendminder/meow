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
