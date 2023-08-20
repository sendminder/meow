import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meow/chat_list.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<int?> createUser(
      String username, String email, String password) async {
    final Uri uri = Uri.parse('http://localhost:8000/users'); // 서버 주소

    final userData = <String, dynamic>{
      'name': username,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      uri,
      body: json.encode(userData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      // 성공적으로 생성된 경우
      print('User created successfully');
      final responseData = json.decode(response.body);
      int? userId = responseData['user']['id']; // 응답에서 ID 추출
      return userId;
    } else {
      // 생성 실패 시
      print('User creation failed');
      return null;
    }
  }

  // 실제로는 서버와 통신하여 로그인을 수행하는 로직이 들어갑니다.
  Future<int?> login(String email, String password) async {
    final Uri uri = Uri.parse('http://localhost:8000/users/login'); // 서버 주소

    final loginData = <String, dynamic>{
      'email': email,
      'password': password,
    };

    final response = await http.post(
      uri,
      body: json.encode(loginData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // 성공적으로 로그인한 경우
      print('User login successfully');
      final responseData = json.decode(response.body);
      int? userId = responseData['user']['Id']; // 응답에서 ID 추출
      return userId;
    } else {
      // 생성 실패 시
      print('User login failed');
      return null;
    }
  }
}

class UserAuthScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('User Authentication')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username')),
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true, // 비밀번호를 가려서 보이지 않게 함
              ),
              ElevatedButton(
                onPressed: () async {
                  int? userId = await _authService.createUser(
                    _usernameController.text,
                    _emailController.text,
                    _passwordController.text,
                  );
                  // 회원 가입 후 화면 전환 코드 추가
                  if (userId != null) {
                    _navigateToChatRoomListScreen(context, userId);
                  }
                },
                child: const Text('Create Account'),
              ),
              ElevatedButton(
                onPressed: () async {
                  int? userId = await _authService.login(
                      _emailController.text, _passwordController.text);
                  // 로그인 후 화면 전환 코드 추가
                  if (userId != null) {
                    _navigateToChatRoomListScreen(context, userId);
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}

void _navigateToChatRoomListScreen(BuildContext context, int userId) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ChatRoomListScreen(userId: userId),
    ),
  );
}
