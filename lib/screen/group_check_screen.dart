import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class GroupCheckScreen extends ConsumerStatefulWidget {
  int? groupId;

  GroupCheckScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupCheckScreen> createState() => _GroupCheckScreenState();
}

class _GroupCheckScreenState extends ConsumerState<GroupCheckScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<List<Ticket>> inviteListFuture;
  late Future<List<Ticket>> receiveListFuture;
  bool isReceive = true;

  Future<List<Ticket>> getInviteList() async {
    var url = Uri.http(baseUri, '/group/getInviteList/${widget.groupId}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = rawData.map((e) => Ticket.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('가입신청보낸목록 가져오기 실패');
    }
  }

  Future<List<Ticket>> getReceiveList() async {
    var url = Uri.http(baseUri, '/group/getReceiveList/${widget.groupId}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = rawData.map((e) => Ticket.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('가입신청받은목록 가져오기 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    inviteListFuture = getInviteList();
    receiveListFuture = getReceiveList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    isReceive = true;
                  });
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: isReceive ? Colors.blueAccent : Colors.blueGrey.shade200),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "받은 가입 요청",
                          style: TextStyle(color: isReceive ? Colors.blueAccent : Colors.blueGrey.shade200, fontSize: 25, fontWeight: FontWeight.bold),
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
                    isReceive = false;
                  });
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: !isReceive ? Colors.blueAccent : Colors.blueGrey.shade200),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "보낸 초대 목록",
                          style: TextStyle(color: !isReceive ? Colors.blueAccent : Colors.blueGrey.shade200, fontSize: 25, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ))
            ],
          ),
          isReceive ? receiveView() : requestView(),
        ],
      ),
    );
  }

  Widget receiveView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('받은 요청이 없습니다'));
                } else {
                  return ListView.builder(
                      itemBuilder: (context, index) {
                        Ticket ticket = snapshot.data![index];
                        return receiveComponent(ticket);
                      },
                      itemCount: snapshot.data!.length);
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
            future: receiveListFuture),
      ),
    );
  }

  Widget requestView() {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.all(20),
      child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('보낸 요청이 없습니다'));
              } else {
                return ListView.builder(
                    itemBuilder: (context, index) {
                      Ticket ticket = snapshot.data![index];
                      return requestComponent(ticket);
                    },
                    itemCount: snapshot.data!.length);
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          future: inviteListFuture),
    ));
  }

  Widget receiveComponent(Ticket ticket) {
    return Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blueGrey.shade200,
              width: 1.5,
            )),
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
                            Text(ticket.memberName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('${ticket.memberId!}', style: TextStyle(color: Colors.grey[500])),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () async {
                          var url = Uri.http(baseUri, '/group/addMember');
                          var response = await http.put(url,
                              headers: {
                                'authorization': 'Bearer $jwtToken',
                                'Content-Type': 'application/json; charset=UTF-8',
                              },
                              body: jsonEncode({
                                'memberId': ticket.memberId,
                                'groupId': widget.groupId,
                              }));
                          if (response.statusCode == 200) {
                            Fluttertoast.showToast(msg: '수락되었습니다');
                            setState(() {
                              receiveListFuture = getReceiveList();
                            });
                          } else {
                            print(utf8.decode(response.bodyBytes));
                          }
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        )),
                    IconButton(
                        onPressed: () {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  title: "가입 요청 거절",
                                  desc: "정말 ${ticket.memberName}님이 보낸 가입 요청을 거절하시겠습니까?",
                                  btnOkOnPress: () async {
                                    var url = Uri.http(baseUri, '/group/deleteMember');
                                    var response = await http.delete(url,
                                        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                        body: jsonEncode({'memberId': ticket.memberId, 'groupId': ticket.groupId}));
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '거절되었습니다');
                                      setState(() {
                                        receiveListFuture = getReceiveList();
                                      });
                                    } else {
                                      print(utf8.decode(response.bodyBytes));
                                    }
                                  },
                                  btnCancelOnPress: () {})
                              .show();
                        },
                        icon: const Icon(
                          // FontAwesomeIcons.x,
                          Icons.remove,
                          color: Colors.red,
                        )),
                  ]),
                ),
              ],
            ),
          ],
        ));
  }

  Widget requestComponent(Ticket ticket) {
    return Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.blueGrey.shade200,
              width: 1.5,
            )),
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
                            Text(ticket.memberName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('${ticket.memberId!}', style: TextStyle(color: Colors.grey[500])),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  title: "보낸 친구 요청 삭제",
                                  desc: "정말 ${ticket.memberName}에게 보낸 초대를 취소하시겠습니까?",
                                  btnOkOnPress: () async {
                                    var url = Uri.http(baseUri, '/group/deleteMember');
                                    var response = await http.delete(url,
                                        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                        body: jsonEncode({'memberId': ticket.memberId, 'groupId': ticket.groupId}));
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '취소되었습니다');
                                      setState(() {
                                        inviteListFuture = getInviteList();
                                      });
                                    } else {
                                      print(utf8.decode(response.bodyBytes));
                                    }
                                  },
                                  btnCancelOnPress: () {})
                              .show();
                        },
                        icon: const Icon(
                          // FontAwesomeIcons.x,
                          Icons.remove,
                          color: Colors.red,
                        ))
                  ]),
                ),
              ],
            ),
          ],
        ));
  }
}
