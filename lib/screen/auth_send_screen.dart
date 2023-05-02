import 'package:flutter/material.dart';

class AuthSendScreen extends StatelessWidget {
  const AuthSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('공강구조대!'),
        backgroundColor: Colors.grey,
      ),
      body: const Text('전송완료'),
    );
  }
}
