import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InvitationScreen extends ConsumerStatefulWidget {
  const InvitationScreen({super.key});

  @override
  ConsumerState<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<InvitationScreen> {
  var jwtToken = AutoLoginController.to.state[0];
  var baseUri = '43.201.208.100:8080';
  Future<List<Group>>? memberReceiveListFuture;
  Future<List<Group>>? memberRequestListFuture;
  bool isRequest = false;
  Future<List<Group>> getMemberReceiveList() async {
    var url = Uri.http(baseUri, '/group/getMemberReceiveList');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('받은 그룹 초대장 가져오기 실패');
    }
  }

  Future<List<Group>> getMemberRequestList() async {
    var url = Uri.http(baseUri, '/group/getMemberRequestList');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('보낸 가입요청 가져오기 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    memberReceiveListFuture = getMemberReceiveList();
    memberRequestListFuture = getMemberRequestList();
  }

  receiveView() {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.all(20),
      child: FutureBuilder(
        future: memberReceiveListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  '받은 요청이 없습니다',
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return ListView.builder(
                  itemBuilder: (context, index) {
                    return receiveComponent(group: snapshot.data![index]);
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
    ));
  }

  receiveComponent({required Group group}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupFinderDetailScreen(
                id: group.groupId,
              ),
            ));
      },
      child: Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blueGrey.shade200,
                width: 1.5,
              )
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.2),
              //     spreadRadius: 0,
              //     blurRadius: 2,
              //     offset: const Offset(0, 1),
              //   ),
              // ],
              ),
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
                            child: const Icon(Icons.group_add),
                          )),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(group.groupName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(group.oneLineInfo!, style: TextStyle(color: Colors.grey[500])),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                          onPressed: () async {
                            var url = Uri.http(baseUri, '/group/acceptInvite/${group.groupId}');
                            var response = await http.put(url, headers: {'authorization': 'Bearer $jwtToken'});
                            if (response.statusCode == 200) {
                              Fluttertoast.showToast(msg: '${group.groupName} 그룹에 가입되었습니다');
                              setState(() {
                                memberReceiveListFuture = getMemberReceiveList();
                              });
                            } else {
                              print(utf8.decode(response.bodyBytes));
                              Fluttertoast.showToast(msg: '가입에 실패하였습니다.');
                            }
                          },
                          icon: const Icon(
                            //FontAwesomeIcons.check,
                            Icons.check,
                            color: Colors.green,
                          )),
                      IconButton(
                          onPressed: () {
                            AwesomeDialog(
                                    context: context,
                                    title: "요청 거절",
                                    desc: "정말 ${group.groupName}그룹에서 보낸 가입 권유를 거절하시겠습니까?",
                                    btnOkOnPress: () async {
                                      var url = Uri.http(baseUri, '/group/deleteMe/${group.groupId}');
                                      var response = await http.delete(url, headers: {
                                        'authorization': 'Bearer $jwtToken',
                                      });
                                      if (response.statusCode == 200) {
                                        Fluttertoast.showToast(msg: '거절되었습니다');
                                        setState(() {
                                          memberReceiveListFuture = getMemberReceiveList();
                                        });
                                      } else {
                                        print(utf8.decode(response.bodyBytes));
                                      }
                                    },
                                    btnCancelOnPress: () {})
                                .show();
                          },
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.red,
                          ))
                    ]),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  requestView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: memberRequestListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('보낸 요청이 없습니다'));
              } else {
                return ListView.builder(
                    itemBuilder: (context, index) {
                      return requestComponent(group: snapshot.data![index]);
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

  requestComponent({required Group group}) {
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
                            Text(group.groupName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(group.oneLineInfo!, style: TextStyle(color: Colors.grey[500])),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: () {
                          AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  title: "보낸 친구 요청 삭제",
                                  desc: "정말 ${group.groupName}그룹에 보낸 가입 신청을 취소하시겠습니까?",
                                  btnOkOnPress: () async {
                                    var url = Uri.http(baseUri, '/group/deleteMe/${group.groupId}');
                                    var response = await http.delete(url, headers: {
                                      'authorization': 'Bearer $jwtToken',
                                    });
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '취소되었습니다');
                                      setState(() {
                                        memberRequestListFuture = getMemberRequestList();
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
      // backgroundColor: const Color.fromARGB(255, 227, 244, 248),
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
                    height: 60,
                    decoration: BoxDecoration(
                        // color: isRequest ? const Color.fromARGB(255, 176, 220, 240) : Colors.blue,
                        border: Border.all(
                          color: isRequest ? Colors.blueGrey.shade200 : Colors.blueAccent,
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "받은 가입 권유",
                            style: TextStyle(color: isRequest ? Colors.blueGrey.shade200 : Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold),
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
                    height: 60,
                    decoration: BoxDecoration(
                        // color: isRequest
                        //     ? Colors.blue
                        //     : const Color.fromARGB(255, 176, 220, 240),
                        border: Border.all(
                          color: isRequest ? Colors.blueAccent : Colors.blueGrey.shade200,
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "보낸 가입 신청",
                            style: TextStyle(color: isRequest ? Colors.blueAccent : Colors.blueGrey.shade200, fontSize: 20, fontWeight: FontWeight.bold),
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
