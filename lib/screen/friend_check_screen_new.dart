import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FriendCheckScreen extends ConsumerStatefulWidget {
  const FriendCheckScreen({super.key});

  @override
  ConsumerState<FriendCheckScreen> createState() => _FriendCheckScreenState();
}

class _FriendCheckScreenState extends ConsumerState<FriendCheckScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<List<Friend>> requestFriendListFuture;
  late Future<List<Friend>> receiveFriendListFuture;
  bool isRequest = false;
  Future<List<Friend>> getRequestFriendList() async {
    var url = Uri.http(baseUri, '/friend/requestList');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Friend.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('친구요청보낸목록 get 실패');
    }
  }

  Future<List<Friend>> getReceiveFriendList() async {
    var url = Uri.http(baseUri, '/friend/receiveList');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Friend.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('친구요청받은목록 get 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    requestFriendListFuture = getRequestFriendList();
    receiveFriendListFuture = getReceiveFriendList();
  }

  receiveView() {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.all(20),
      child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Text(
                  '받은 요청이 없습니다',
                  textAlign: TextAlign.center,
                );
              } else {
                return ListView.builder(
                    itemBuilder: (context, index) {
                      return receiveComponent(friend: snapshot.data![index]);
                    },
                    itemCount: snapshot.data!.length);
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          future: receiveFriendListFuture),
    ));
  }

  receiveComponent({required Friend friend}) {
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromARGB(255, 255, 255, 255), boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    SizedBox(
                        width: 30,
                        height: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          // child: Image.asset(job.companyLogo),
                          child: const Icon(Icons.person_add),
                        )),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(friend.friendName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () async {
                          var url = Uri.http(baseUri, '/friend/add/${friend.friendId}');
                          var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
                          if (response.statusCode == 200) {
                            Fluttertoast.showToast(msg: '수락되었습니다');
                            setState(() {
                              receiveFriendListFuture = getReceiveFriendList();
                            });
                          } else {
                            print(utf8.decode(response.bodyBytes));
                          }
                        },
                        icon: const Icon(
                          FontAwesomeIcons.check,
                          color: Colors.green,
                        )),
                    IconButton(
                        onPressed: () {
                          AwesomeDialog(
                                  context: context,
                                  title: "요청 거절",
                                  desc: "정말 ${friend.friendName}님이 보낸 친구 요청을 거절하시겠습니까?",
                                  btnOkOnPress: () async {
                                    var url = Uri.http(baseUri, '/friend/deny/${friend.friendId}');
                                    var response = await http.delete(url, headers: {'authorization': 'Bearer $jwtToken'});
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '거절되었습니다');
                                      setState(() {
                                        receiveFriendListFuture = getReceiveFriendList();
                                      });
                                    } else {
                                      print(utf8.decode(response.bodyBytes));
                                    }
                                  },
                                  btnCancelOnPress: () {})
                              .show();
                        },
                        icon: const Icon(
                          FontAwesomeIcons.x,
                          color: Colors.red,
                        ))
                  ]),
                ),
              ],
            ),
          ],
        ));
  }

  requestView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: requestFriendListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Text('보낸 요청이 없습니다');
              } else {
                return ListView.builder(
                    itemBuilder: (context, index) {
                      return requestComponent(friend: snapshot.data![index]);
                    },
                    itemCount: snapshot.data!.length);
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  requestComponent({required Friend friend}) {
    return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromARGB(255, 255, 255, 255), boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(children: [
                    SizedBox(
                        width: 30,
                        height: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          // child: Image.asset(job.companyLogo),
                          child: const Icon(FontAwesomeIcons.person),
                        )),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(friend.friendName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  title: "보낸 친구 요청 삭제",
                                  desc: "정말 ${friend.friendName}님에게 보낸 친구 요청을 취소하시겠습니까?",
                                  btnOkOnPress: () async {
                                    var url = Uri.http(baseUri, '/friend/delete/${friend.friendId}');
                                    var response = await http.delete(url, headers: {'authorization': 'Bearer $jwtToken'});
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '삭제되었습니다');
                                      setState(() {
                                        requestFriendListFuture = getRequestFriendList();
                                      });
                                    }
                                  },
                                  btnCancelOnPress: () {})
                              .show();
                        },
                        icon: const Icon(
                          FontAwesomeIcons.x,
                          color: Colors.red,
                        ))
                  ]),
                ),
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Navigator.of(context).maybePop();
            Navigator.pop(context, true);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 227, 244, 248),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isRequest = false;
                    });
                  },
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: isRequest ? const Color.fromARGB(255, 176, 220, 240) : Colors.blue,
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "받은 친구 요청",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isRequest = true;
                    });
                  },
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                        color: isRequest ? Colors.blue : const Color.fromARGB(255, 176, 220, 240),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "보낸 친구 요청",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
            isRequest ? requestView() : receiveView()
          ],
        ),
      ),
    );
  }
}
