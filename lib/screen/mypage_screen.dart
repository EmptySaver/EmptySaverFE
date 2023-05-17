import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class MypageScreen extends ConsumerStatefulWidget {
  const MypageScreen({super.key});

  @override
  ConsumerState<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends ConsumerState<MypageScreen> {
  var baseUri = '43.201.208.100:8080';
  late var jwtToken;
  late Future<MemberInfo> memberInfoFuture;

  var nicknameTec = TextEditingController();
  var pwdTec = TextEditingController();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          OutlinedButton(
              onPressed: () async {
                var url = Uri.http(baseUri, '/afterAuth/deleteme');
                var response = await http.delete(url,
                    headers: {'authorization': 'Bearer $jwtToken'});
                if (response.statusCode == 200) {
                  Fluttertoast.showToast(msg: '회원탈퇴되었습니다');
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                }
              },
              child: const Text('탈퇴'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.person,
                      size: 100,
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    FutureBuilder(
                      future: memberInfoFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              Text('이메일 주소 : ${snapshot.data!.email!}'),
                              Text('이름 : ${snapshot.data!.name!}'),
                              Text('닉네임 : ${snapshot.data!.nickname!}'),
                              Text('학번 : ${snapshot.data!.classOf!}'),
                            ],
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          contentPadding: const EdgeInsets.all(10),
                          title: const Text('닉네임 변경'),
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  hintText: '변경할 닉네임을 입력하세요',
                                  labelText: 'Nickname'),
                              controller: nicknameTec,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            OutlinedButton(
                                onPressed: () async {
                                  var url = Uri.http(baseUri,
                                      '/afterAuth/changeNickName/${nicknameTec.text}');
                                  var response = await http.put(url, headers: {
                                    'authorization': 'Bearer $jwtToken'
                                  });
                                  if (response.statusCode == 200) {
                                    Fluttertoast.showToast(msg: '변경되었습니다');
                                    setState(() {
                                      memberInfoFuture = getMemberInfo();
                                    });
                                    Navigator.pop(context);
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                    Fluttertoast.showToast(msg: '변경 에러');
                                  }
                                },
                                child: const Text('변경하기'))
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('닉네임 변경')),
              TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          contentPadding: const EdgeInsets.all(10),
                          title: const Text('비밀번호 변경'),
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.person),
                                  hintText: '변경할 비밀번호를 입력하세요',
                                  labelText: '비밀번호'),
                              controller: pwdTec,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            OutlinedButton(
                                onPressed: () async {
                                  var url = Uri.http(
                                      baseUri, '/afterAuth/changePassword');
                                  var response = await http.put(url, headers: {
                                    'authorization': 'Bearer $jwtToken'
                                  });
                                  if (response.statusCode == 200) {
                                    Fluttertoast.showToast(msg: '변경되었습니다');
                                    Navigator.pop(context);
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                    Fluttertoast.showToast(msg: '변경 에러');
                                  }
                                },
                                child: const Text('변경하기'))
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('비밀번호 변경'))
            ],
          ),
        ),
      ),
    );
  }
}
