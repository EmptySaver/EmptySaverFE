import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var isClicked = false;
  var isauthed = false;
  TextEditingController addrTec = TextEditingController();
  TextEditingController pwdTec = TextEditingController();
  TextEditingController classnumTec = TextEditingController();
  TextEditingController nameTec = TextEditingController();
  TextEditingController nicknameTec = TextEditingController();
  TextEditingController authTec = TextEditingController();
  late String authResponse;

  void postMyEmail() async {
    isClicked = true;
    var url =
        Uri.parse('http://43.201.208.100:8080/auth/sendEmail/${addrTec.text}');
    var response = await http.post(
      url,
      // body: jsonEncode(<String, String>{
      //   'email': '',
      // }),
      //headers: <String, String>{'Content-Type': 'text/plain; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      print(response.body);
      authResponse = response.body;
    } else {
      print(response.statusCode);
    }
  }

  void postSignUp() async {
    var url = Uri.parse('http://43.201.208.100:8080/auth/signup');
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'email': addrTec.text,
        'password': pwdTec.text,
        'classOf': classnumTec.text,
        'name': nameTec.text,
        'nickname': nicknameTec.text,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );
    if (response.statusCode == 200) {
      print('good');
      Navigator.pop(context);
    } else {
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('공강구조대!'),
        backgroundColor: Colors.grey,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              heightFactor: 1.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('학교 이메일 주소'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: addrTec,
                    decoration: const InputDecoration(
                      labelText: '주소',
                      hintText: '@uos.ac.kr',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: isauthed
                            ? null
                            : () {
                                setState(() {
                                  postMyEmail();
                                });
                              },
                        child: Text(
                          isauthed ? '인증완료' : '이메일 인증',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: isClicked,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: authTec,
                          decoration: const InputDecoration(
                            labelText: '인증코드',
                            hintText: '코드를 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        //전송, 재전송버튼
                        OutlinedButton(
                          onPressed: () {
                            if (authTec.text == authResponse) {
                              Fluttertoast.showToast(msg: '인증되었습니다');
                              isauthed = true;
                              setState(() {
                                isClicked = false;
                              });
                            } else {
                              Fluttertoast.showToast(msg: '코드가 다릅니다');
                            }
                          },
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Text('비밀번호'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: pwdTec,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('학번'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: classnumTec,
                    decoration: const InputDecoration(
                      labelText: '학번',
                      hintText: '학번 10자리',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('실명'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nameTec,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('닉네임'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nicknameTec,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      // hintText: '학번 10자리',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: postSignUp,
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey)),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
