import 'dart:convert';
import 'package:emptysaver_fe/widgets/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:emptysaver_fe/core/assets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

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
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      print(result['message']);
      Fluttertoast.showToast(msg: '${result['message']}');
    }
  }

  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30.0,
          ),
          const Image(
              image: AssetImage('assets/logoVer2.png'),
              width: 250,
              height: 150,
              color: Colors.blueAccent,
          ),
          _buildLoginForm(),
          const SizedBox(
            height: 20.0,
          ),
          //_buildLoginForm(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[
          //     FloatingActionButton(
          //       mini: true,
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       backgroundColor: Colors.blue,
          //       child: const Icon(Icons.arrow_back),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  Container _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
            Container(
              height: 280,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(40.0)), border: Border.all(color: Colors.blueAccent)),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 40.0,
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: addrTecFind,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "Email address",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.email,
                              color: Colors.blue,
                            )),
                      )),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        controller: nameTecFind,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "Name(실명)",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.lock,
                              color: Colors.blue,
                            )),
                      )),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(0.0, -30),
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.blue.shade600,
                  child: const Icon(
                    Icons.lock_reset_sharp,
                    size: 45,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 380,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: OutlinedButton(
                onPressed: isSended
                    ? null
                    : () {
                        findMyPwd();
                      },
                child: Text(isSended ? '완료' : '비밀번호 초기화',
                   ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _buildPageContent(context),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       toolbarHeight: 50,
  //       centerTitle: true,
  //       title: const Text('공강구조대!'),
  //       backgroundColor: Colors.grey,
  //     ),
  //     body: GestureDetector(
  //       onTap: () => FocusScope.of(context).unfocus(),
  //       child: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Center(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const SizedBox(
  //                   height: 150,
  //                 ),
  //                 const Text('학교 이메일 주소'),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 TextField(
  //                   controller: addrTecFind,
  //                   decoration: const InputDecoration(
  //                     labelText: '주소',
  //                     hintText: '@uos.ac.kr',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(10)),
  //                     ),
  //                   ),
  //                   keyboardType: TextInputType.emailAddress,
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 const Text('이름'),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 TextField(
  //                   controller: nameTecFind,
  //                   decoration: const InputDecoration(
  //                     labelText: '이름',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.all(Radius.circular(10)),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     OutlinedButton(
  //                         onPressed: isSended
  //                             ? null
  //                             : () {
  //                                 findMyPwd();
  //                               },
  //                         child: Text(
  //                           isSended ? '완료' : '인증하기',
  //                           style: const TextStyle(color: Colors.black),
  //                         ))
  //                   ],
  //                 ),
  //                 // Visibility(
  //                 //   visible: isClicked,
  //                 //   child: Column(
  //                 //     crossAxisAlignment: CrossAxisAlignment.end,
  //                 //     children: [
  //                 //       const TextField(
  //                 //         decoration: InputDecoration(
  //                 //           labelText: '인증코드',
  //                 //           hintText: '코드를 입력하세요',
  //                 //           border: OutlineInputBorder(
  //                 //             borderRadius:
  //                 //                 BorderRadius.all(Radius.circular(10)),
  //                 //           ),
  //                 //         ),
  //                 //         keyboardType: TextInputType.number,
  //                 //       ),
  //                 //       const SizedBox(
  //                 //         height: 10,
  //                 //       ),
  //                 //       //전송, 재전송버튼
  //                 //       OutlinedButton(
  //                 //         onPressed: () {
  //                 //           //요청이 성공하면 끝 , 실패하면 토스트
  //                 //         },
  //                 //         child: const Text(
  //                 //           '확인',
  //                 //           style: TextStyle(
  //                 //             color: Colors.black,
  //                 //           ),
  //                 //         ),
  //                 //       )
  //                 //     ],
  //                 //   ),
  //                 // ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
