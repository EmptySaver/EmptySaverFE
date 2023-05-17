import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:emptysaver_fe/core//assets.dart';
import 'package:emptysaver_fe/widgets/network_image.dart';

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
  TextEditingController pwdTec2 = TextEditingController();
  TextEditingController classnumTec = TextEditingController();
  TextEditingController nameTec = TextEditingController();
  TextEditingController nicknameTec = TextEditingController();
  TextEditingController authTec = TextEditingController();
  late String authResponse;
  Timer? _timer;
  var _time = 100;

  static const String path = "lib/src/pages/login/signup1.dart";

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    //여기서 뭐 에러가나는거같긴도한디..?
  }

  void _setTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_time == 1) {
          print("timeout");
          isClicked = false;
          setState(() {});
          dispose();
        }
        _time--;
      });
    });
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });

        return AlertDialog(
          title: const Text("공강구조대"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          content: Text(text),
        );
      },
    );
  }

  bool _checkSpace(String target) {
    String result = target.replaceAll(RegExp('\\s'), "");
    print("result leng: ${result.length} target leng: ${target.length}");
    print("result: ${result.toString()} target: ${target.toString()}");
    return result.length == target.length;
  }

  void postMyEmail() async {
    List<String> emailList = addrTec.text.split("@");
    // if (emailList.length != 2) {
    //   this._showDialog("이메일을 확인 해주세요");
    //   return;
    // } else if (emailList[1] != "uos.ac.kr") {
    //   this._showDialog("학교 이메일 형식이어야 합니다!");
    //   return;
    // }
    String addr = addrTec.text;
    if (!_checkSpace(addr)) {
      _showDialog("공백은 허용되지 않습니다");
      return;
    }
    if (addr.isEmpty) {
      Fluttertoast.showToast(msg: '이메일을 입력해주세요');
      return;
    }

    isClicked = true;
    var url =
        Uri.parse('http://43.201.208.100:8080/auth/sendEmail/${addrTec.text}');
    _time = 100;
    _setTimer();
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
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      _showDialog(result['message']);
    }
  }

  void postSignUp() async {
    if (!isauthed) {
      _showDialog("이메일 인증 후 진행해주세요");
      return;
    }
    if (!_checkSpace(addrTec.text) ||
        !_checkSpace(pwdTec.text) ||
        !_checkSpace(classnumTec.text) ||
        !_checkSpace(nameTec.text) ||
        !_checkSpace(nicknameTec.text)) {
      _showDialog("공백은 허용되지 않습니다");
      return;
    }

    // if (emailList.length != 2) {
    //   this._showDialog("이메일을 확인 해주세요");
    //   return;
    // } else if (emailList[1] != "uos.ac.kr") {
    //   this._showDialog("학교 이메일 형식이어야 합니다!");
    //   return;
    // }
    if (pwdTec.text != pwdTec2.text) {
      _showDialog("비밀번호를 확인해주세요");
      return;
    }
    var num = int.parse(classnumTec.text);
    if (num < 2000000000 || num > 2100000000) {
      _showDialog("학번을 확인해주세요");
      return;
    }

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
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      _showDialog(result['message']);
      isClicked = false;
    }
  }

  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30.0,
          ),
          const CircleAvatar(
            maxRadius: 50,
            backgroundColor: Colors.transparent,
            child: PNetworkImage(origami),
          ),
          const SizedBox(
            height: 20.0,
          ),
          _buildLoginForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.arrow_back),
              )
            ],
          )
        ],
      ),
    );
  }

  Container _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 750,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 90.0,
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          AbsorbPointer(
                              absorbing: isauthed,
                              child: SizedBox(
                                width: 240,
                                child: TextField(
                                  controller: addrTec,
                                  style: const TextStyle(color: Colors.blue),
                                  decoration: InputDecoration(
                                      hintText: "@uos.ac.kr",
                                      hintStyle: TextStyle(
                                          color: Colors.blue.shade200),
                                      border: InputBorder.none,
                                      icon: const Icon(
                                        Icons.email,
                                        color: Colors.blue,
                                      )),
                                ),
                              )),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                            ),
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
                                  color: Colors.cyan, fontSize: 10),
                            ),
                          ),
                        ],
                      )),
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
                        ),
                        Text(
                          "남은시간 : $_time",
                          style: const TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                  ),
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
                        controller: pwdTec,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.lock,
                              color: Colors.blue,
                            )),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
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
                        controller: pwdTec2,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "Confirm password",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.lock,
                              color: Colors.blue,
                            )),
                        obscureText: true,
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
                        controller: classnumTec,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "학번(ex, 20xx9200xx)",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.school,
                              color: Colors.blue,
                            )),
                        keyboardType: TextInputType.visiblePassword,
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
                        controller: nameTec,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "이름",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            )),
                        keyboardType: TextInputType.visiblePassword,
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
                        controller: nicknameTec,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "닉네임",
                            hintStyle: TextStyle(color: Colors.blue.shade200),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.person_off,
                              color: Colors.blue,
                            )),
                        keyboardType: TextInputType.visiblePassword,
                      )),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.blue.shade600,
                child: const Icon(Icons.person),
              ),
            ],
          ),
          SizedBox(
            height: 770,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60.0)),
                  backgroundColor: Colors.blue,
                ),
                onPressed: postSignUp,
                child: const Text("Sign Up",
                    style: TextStyle(color: Colors.white70)),
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
      body: _buildPageContent(context),
    );
  }
}
