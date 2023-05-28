import 'dart:convert';
import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/screen/member_interest_screen.dart';
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
  static const storage = FlutterSecureStorage();
  dynamic userInfo = '';
  bool isAutoLogin = false;
  bool isIdSave = false;
  TextEditingController addrTecLogin = TextEditingController();
  TextEditingController pwdTecLogin = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      asyncMethod();
    });
  }

  asyncMethod() async {
    userInfo = await storage.read(key: 'login');
    if (userInfo != null) {
      bool authSuccess = await gettokenForAutoLogin(jsonDecode(userInfo));
      if (authSuccess) {
        Navigator.pushNamed(context, '/bar');
      } else {
        print('bar로 이동은 못함');
      }
    } else {
      print('유저정보 없음, 로그인 필요');
    }
  }

  Future<bool> gettokenForAutoLogin(dynamic decodedUserInfo) async {
    var url = Uri.parse('http://43.201.208.100:8080/auth/login');
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': decodedUserInfo['email'],
          'password': decodedUserInfo['password'],
          'fcmToken': decodedUserInfo['fcmToken'],
        }));
    if (response.statusCode == 200) {
      print('자동로그인성공, jwt토큰발급');
      await storage.write(key: 'jwtToken', value: response.body);
      var jwtToken = await storage.read(key: 'jwtToken');
      AutoLoginController.to.addToken(jwtToken!);
      return true;
    } else {
      return false;
    }
  }

  void postLogin() async {
    var url = Uri.parse('http://43.201.208.100:8080/auth/login');
    List<String> emailList = addrTecLogin.text.split("@");
    // if (emailList.length != 2) {
    //   Fluttertoast.showToast(msg: '이메일을 확인 해주세요');
    //   return;
    // } else if (emailList[1] != "uos.ac.kr") {
    //   Fluttertoast.showToast(msg: '학교이메일 형식만 허용됩니다');
    //   return;
    // }
    Map<String, dynamic> loginInfo = {
      'email': addrTecLogin.text,
      'password': pwdTecLogin.text,
      'fcmToken': widget.firebaseToken!,
    };
    var response = await http.post(
      url,
      body: jsonEncode(loginInfo),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'authorization' :
      },
    );
    if (response.statusCode == 200) {
      if (isAutoLogin) {
        await storage.write(key: 'login', value: jsonEncode(loginInfo));
        print('유저정보 저장');
      }
      await storage.write(key: 'jwtToken', value: response.body);
      var jwtToken = await storage.read(key: 'jwtToken');
      AutoLoginController.to.addToken(jwtToken!);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BarScreen(),
          ),
              (route) => false);
    } else {
      var result = utf8.decode(response.bodyBytes);
      print(result);
      Fluttertoast.showToast(msg: '로그인에 실패하였습니다');
    }
  }

  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 60.0,
          ),
          Image(
              image: AssetImage('assets/logoVer2.png'),
              width: 250,
              height: 150),
          _buildLoginForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => SignupScreen(
                            firebaseToken: widget.firebaseToken,
                          )));
                },
                child: const Text("Sign Up",
                    style: TextStyle(color: Colors.blue, fontSize: 18.0)),
              ),
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
          //ClipPath(
            //clipper: RoundedDiagonalPathClipper(),
            //child:
            Container(
              //height: 400,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 60.0,
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
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Checkbox(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        value: isAutoLogin,
                        onChanged: (value) {
                          setState(() {
                            isAutoLogin = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text('자동 로그인'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          print('Getjwt : ${AutoLoginController.to.state}');
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