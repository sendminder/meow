import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:provider/provider.dart';

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
