import 'dart:convert';

import 'package:emptysaver_fe/widgets/find_password_screen.dart';
import 'package:emptysaver_fe/widgets/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  String? firebaseToken;

  LoginScreen({
    super.key,
    required this.firebaseToken,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool? isAutoLogin = false;
  bool? isIdSave = false;
  TextEditingController addrTecLogin = TextEditingController();
  TextEditingController pwdTecLogin = TextEditingController();

  void postLogin() async {
    var url = Uri.parse('http://43.201.208.100:8080/auth/login');
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'email': addrTecLogin.text,
        'password': pwdTecLogin.text,
        'fcmToken': widget.firebaseToken!,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );
    print(response.statusCode);
    // if (response.statusCode == 200) {
    //   Navigator.pushNamedAndRemoveUntil(context, '/bar', (route) => false);
    // } else {
    //   print(response.statusCode);
    // }
  }

  @override
  Widget build(BuildContext context) {
    print('login:${widget.firebaseToken}');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('공강구조대!'),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        heightFactor: 1.2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text('이메일'),
                  const SizedBox(
                    height: 10,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '주소',
                      hintText: '@uos.ac.kr',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text('비밀번호'),
                  const SizedBox(
                    height: 10,
                  ),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        value: isAutoLogin,
                        onChanged: (value) {
                          setState(() {
                            isAutoLogin = value;
                          });
                        },
                      ),
                      const Text('자동 로그인'),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          onPressed: postLogin,
                          style: OutlinedButton.styleFrom(
                              // shape: const StadiumBorder(),
                              side: const BorderSide(color: Colors.grey)),
                          child: const Text(
                            '로그인',
                            style: TextStyle(color: Colors.black),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FindPasswordScreen(),
                                  ));
                            },
                            child: const Text('비밀번호 찾기'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ));
                            },
                            child: const Text('회원가입'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
