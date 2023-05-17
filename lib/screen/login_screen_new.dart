import 'dart:convert';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:emptysaver_fe/screen/find_password_screen.dart';
import 'package:emptysaver_fe/screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bar_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:emptysaver_fe/core/assets.dart';
import 'package:emptysaver_fe/widgets/network_image.dart';

class NewLoginScreen extends ConsumerStatefulWidget {
  String? firebaseToken;
  NewLoginScreen({
    super.key,
    required this.firebaseToken,
  });

  @override
  ConsumerState<NewLoginScreen> createState() => _LoginScreenStateNew();
}

class _LoginScreenStateNew extends ConsumerState<NewLoginScreen> {
  final storage = const FlutterSecureStorage();
  bool? isAutoLogin = false;
  bool? isIdSave = false;
  TextEditingController addrTecLogin = TextEditingController();
  TextEditingController pwdTecLogin = TextEditingController();

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

  void postLogin() async {
    var url = Uri.parse('http://43.201.208.100:8080/auth/login');
    List<String> emailList = addrTecLogin.text.split("@");
    // if (emailList.length != 2) {
    //   this._showDialog("이메일을 확인 해주세요");
    //   return;
    // } else if (emailList[1] != "uos.ac.kr") {
    //   this._showDialog("학교 이메일 형식이어야 합니다!");
    //   return;
    // }
    var response = await http.post(
      url,
      body: jsonEncode(<String, String>{
        'email': addrTecLogin.text,
        'password': pwdTecLogin.text,
        'fcmToken': widget.firebaseToken!,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'authorization' :
      },
    );

    if (response.statusCode == 200) {
      await storage.write(key: 'login', value: response.body);
      var jwtToken = await storage.read(key: 'login');
      ref.read(tokensProvider.notifier).addToken(jwtToken);
      // var test = ref.read(tokensProvider.notifier).state[1];
      // print('됐냐 : $test');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BarScreen(),
          ),
          (route) => false);
    } else {
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      print(result['message']);
      // _showDialog(result['message']);
      Fluttertoast.showToast(msg: '${result['message']}');
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const SignupScreen()));
                },
                child: const Text("Sign Up",
                    style: TextStyle(color: Colors.blue, fontSize: 18.0)),
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
              height: 400,
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
                      child: TextField(
                        controller: addrTecLogin,
                        style: const TextStyle(color: Colors.blue),
                        decoration: InputDecoration(
                            hintText: "@uos.ac.kr",
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
                        controller: pwdTecLogin,
                        style: const TextStyle(color: Colors.blue),
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Password",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const FindPasswordScreen()));
                        },
                        child: const Text(
                          "Forgot Password",
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    ],
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
            height: 420,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0)),
                  backgroundColor: Colors.blue,
                ),
                onPressed: postLogin,
                child: const Text("Login",
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
    print('fcmToken:${widget.firebaseToken}');
    return Scaffold(
      body: _buildPageContent(context),
    );
  }
}
