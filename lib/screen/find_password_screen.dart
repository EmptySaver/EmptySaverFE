import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  var isSended = false;

  TextEditingController addrTecFind = TextEditingController();

  TextEditingController nameTecFind = TextEditingController();

  void findMyPwd() async {
    var url = Uri.parse('http://43.201.208.100:8080/auth/findPassword');
    var response = await http.put(
      url,
      body: jsonEncode(<String, String>{
        'email': addrTecFind.text,
        'name': nameTecFind.text
      }),
      headers: <String, String>{'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print(response.body);
      isSended = true;
      Fluttertoast.showToast(msg: '이메일로 새 비밀번호를 전송했습니다');
      Navigator.pop(context);
    } else {
      print(jsonDecode(response.body));
      Fluttertoast.showToast(msg: '인증이 실패했습니다');
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  const Text('학교 이메일 주소'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: addrTecFind,
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
                    height: 20,
                  ),
                  const Text('이름'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nameTecFind,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          onPressed: isSended
                              ? null
                              : () {
                                  findMyPwd();
                                },
                          child: Text(
                            isSended ? '완료' : '인증하기',
                            style: const TextStyle(color: Colors.black),
                          ))
                    ],
                  ),
                  // Visibility(
                  //   visible: isClicked,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.end,
                  //     children: [
                  //       const TextField(
                  //         decoration: InputDecoration(
                  //           labelText: '인증코드',
                  //           hintText: '코드를 입력하세요',
                  //           border: OutlineInputBorder(
                  //             borderRadius:
                  //                 BorderRadius.all(Radius.circular(10)),
                  //           ),
                  //         ),
                  //         keyboardType: TextInputType.number,
                  //       ),
                  //       const SizedBox(
                  //         height: 10,
                  //       ),
                  //       //전송, 재전송버튼
                  //       OutlinedButton(
                  //         onPressed: () {
                  //           //요청이 성공하면 끝 , 실패하면 토스트
                  //         },
                  //         child: const Text(
                  //           '확인',
                  //           style: TextStyle(
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
