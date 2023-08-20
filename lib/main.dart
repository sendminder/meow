import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meow/chat_list.dart';
import 'package:meow/auth.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meow',
      home: UserAuthScreen(), // 사용자 ID를 전달
    );
  }
}
