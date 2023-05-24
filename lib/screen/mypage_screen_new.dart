import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MypageScreenOneState();
}

class _MypageScreenOneState extends ConsumerState<MyPageScreen> {
  late bool _dark;
  var baseUri = '43.201.208.100:8080';
  late var jwtToken;
  late Future<MemberInfo> memberInfoFuture;

  var nicknameTec = TextEditingController();
  var oldPwdTec = TextEditingController();
  var newPwdTec = TextEditingController();

  bool isMoreInfo = false;

  Future<MemberInfo> getMemberInfo() async {
    var url = Uri.http(baseUri, '/afterAuth/getMemberInfo');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    var data = MemberInfo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    return data;
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    memberInfoFuture = getMemberInfo();
    _dark = false;
  }

  Brightness _getBrightness() {
    return _dark ? Brightness.dark : Brightness.light;
  }

  bool _checkSpace(String target) {
    String result = target.replaceAll(RegExp('\\s'), "");
    return result.length == target.length;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: _getBrightness(),
      ),
      child: Scaffold(
        backgroundColor: _dark ? null : Color.fromARGB(255, 220, 241, 248),
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle:
              _dark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: _dark ? Colors.white : Colors.black),
          backgroundColor: Colors.transparent,
          title: Text(
            'MyPage',
            style: TextStyle(color: _dark ? Colors.white : Colors.black),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(FontAwesomeIcons.moon),
              onPressed: () {
                setState(() {
                  _dark = !_dark;
                });
              },
            )
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color: Color.fromARGB(255, 63, 118, 185),
                      child: FutureBuilder(
                        future: memberInfoFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    //open edit profile
                                    setState(() {
                                      isMoreInfo = !isMoreInfo;
                                    });
                                  },
                                  title: Text(
                                    '환영합니다, ${snapshot.data!.name!}님',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // 나중에 뭐 프로필 사진 추가 기능 넣으면 여기에 프사표시
                                  // leading: CircleAvatar(
                                  //   backgroundImage: NetworkImage(avatars[0]),
                                  // ),
                                  trailing: isMoreInfo
                                      ? const Icon(
                                          FontAwesomeIcons.angleUp,
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          FontAwesomeIcons.angleDown,
                                          color: Colors.white,
                                        ),
                                ),
                                _buildDivider(),
                                Visibility(
                                    visible: isMoreInfo,
                                    child: Column(
                                      children: [
                                        ListTile(
                                            leading: const Icon(
                                              Icons.email,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              "${snapshot.data!.email}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )),
                                        _buildDivider(),
                                        ListTile(
                                            leading: const Icon(
                                              Icons.school,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              "${snapshot.data!.classOf}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )),
                                        _buildDivider(),
                                        ListTile(
                                            leading: const Icon(
                                              FontAwesomeIcons.personRays,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              "${snapshot.data!.nickname}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )),
                                      ],
                                    )),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )),
                  const SizedBox(height: 10.0),
                  Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(
                            Icons.lock_outline,
                            color: Colors.cyan,
                          ),
                          title: const Text("비밀번호 변경"),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            //open change password
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.question,
                              body: Column(
                                children: [
                                  const Text(
                                    "비밀번호 변경",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 60, 60, 69),
                                        fontSize: 22),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        icon: Icon(Icons.lock),
                                        hintText: '기존 비밀번호를 입력하세요',
                                        labelText: '기존 비밀번호'),
                                    controller: oldPwdTec,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        icon: Icon(Icons.lock,
                                            color: Colors.cyan),
                                        hintText: '변경할 비밀번호를 입력하세요',
                                        labelText: '새 비밀번호'),
                                    controller: newPwdTec,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                              btnOkOnPress: () async {
                                if (!_checkSpace(newPwdTec.text)) {
                                  Fluttertoast.showToast(msg: '공백은 허용되지 않습니다');
                                  return;
                                }
                                var url = Uri.http(
                                    baseUri, '/afterAuth/changePassword');
                                var response = await http.put(url,
                                    headers: {
                                      'authorization': 'Bearer $jwtToken',
                                      'Content-Type':
                                          'application/json; charset=UTF-8'
                                    },
                                    body: jsonEncode({
                                      'oldPassword': oldPwdTec.text,
                                      'newPassword': newPwdTec.text,
                                    }));
                                if (response.statusCode == 200) {
                                  Fluttertoast.showToast(msg: '변경되었습니다');
                                } else {
                                  var result = jsonDecode(
                                      utf8.decode(response.bodyBytes));
                                  print(result['message']);
                                  Fluttertoast.showToast(
                                      msg: '${result['message']}');
                                }
                              },
                              btnCancelOnPress: () {},
                            ).show();
                          },
                        ),
                        _buildDivider(),
                        FutureBuilder(
                            future: memberInfoFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListTile(
                                  leading: const Icon(
                                    FontAwesomeIcons.person,
                                    color: Colors.cyan,
                                  ),
                                  title: const Text("닉네임 변경"),
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                  onTap: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.question,
                                      body: Column(
                                        children: [
                                          Text(
                                              "현재 닉네임 : ${snapshot.data!.nickname!}"),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                                icon: Icon(
                                                  FontAwesomeIcons.person,
                                                  color: Colors.cyan,
                                                ),
                                                hintText: '변경할 닉네임을 입력하세요',
                                                labelText: 'Nickname'),
                                            controller: nicknameTec,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      btnOkOnPress: () async {
                                        if (!_checkSpace(nicknameTec.text)) {
                                          Fluttertoast.showToast(
                                              msg: '공백은 허용되지 않습니다');
                                          return;
                                        }
                                        var url = Uri.http(baseUri,
                                            '/afterAuth/changeNickName/${nicknameTec.text}');
                                        var response = await http
                                            .put(url, headers: {
                                          'authorization': 'Bearer $jwtToken'
                                        });
                                        if (response.statusCode == 200) {
                                          Fluttertoast.showToast(
                                              msg: '변경되었습니다');
                                          setState(() {
                                            memberInfoFuture = getMemberInfo();
                                            nicknameTec.text = "";
                                          });
                                        } else {
                                          print(
                                              utf8.decode(response.bodyBytes));
                                          Fluttertoast.showToast(msg: '변경 에러');
                                        }
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                        _buildDivider(),
                        ListTile(
                          leading: const Icon(
                            Icons.delete_forever,
                            color: Colors.cyan,
                          ),
                          title: const Text("회원 탈퇴"),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              title: "회원 탈퇴",
                              desc: "정말 탈퇴하시겠습니까?",
                              btnOkOnPress: () async {
                                var url =
                                    Uri.http(baseUri, '/afterAuth/deleteme');
                                var response = await http.delete(url, headers: {
                                  'authorization': 'Bearer $jwtToken'
                                });
                                if (response.statusCode == 200) {
                                  Fluttertoast.showToast(msg: '회원탈퇴되었습니다');
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false);
                                }
                              },
                              btnCancelOnPress: () {},
                            ).show();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  //알림관련 설정하는 부분인데 나중에 뭐 구현하던가..합시다
                  // const Text(
                  //   "Notification Settings",
                  //   style: TextStyle(
                  //     fontSize: 20.0,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.indigo,
                  //   ),
                  // ),
                  // SwitchListTile(
                  //   activeColor: Colors.cyan,
                  //   contentPadding: const EdgeInsets.all(0),
                  //   value: true,
                  //   title: const Text("Received notification"),
                  //   onChanged: (val) {},
                  // ),
                  // const SwitchListTile(
                  //   activeColor: Colors.cyan,
                  //   contentPadding: EdgeInsets.all(0),
                  //   value: false,
                  //   title: Text("Received newsletter"),
                  //   onChanged: null,
                  // ),
                  // SwitchListTile(
                  //   activeColor: Colors.cyan,
                  //   contentPadding: const EdgeInsets.all(0),
                  //   value: true,
                  //   title: const Text("Received Offer Notification"),
                  //   onChanged: (val) {},
                  // ),
                  // const SwitchListTile(
                  //   activeColor: Colors.cyan,
                  //   contentPadding: EdgeInsets.all(0),
                  //   value: true,
                  //   title: Text("Received App Updates"),
                  //   onChanged: null,
                  // ),
                  // const SizedBox(height: 60.0),
                ],
              ),
            ),
            // Positioned(
            //   bottom: -20,
            //   left: -20,
            //   child: Container(
            //     width: 80,
            //     height: 80,
            //     alignment: Alignment.center,
            //     decoration: const BoxDecoration(
            //       color: Colors.blue,
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),
            // Positioned(
            //   bottom: 00,
            //   left: 00,
            //   child: IconButton(
            //     icon: const Icon(
            //       FontAwesomeIcons.powerOff,
            //       color: Colors.white,
            //     ),
            //     onPressed: () {
            //       //log out
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
