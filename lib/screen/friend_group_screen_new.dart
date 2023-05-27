import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/category_select_screen.dart';
import 'package:emptysaver_fe/screen/friend_check_screen_new.dart';
import 'package:emptysaver_fe/screen/group_detail_screen.dart';
import 'package:emptysaver_fe/screen/invitation_screen_new.dart';
import 'package:emptysaver_fe/screen/invitation_screen_legacy.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';

class FriendGroupScreen extends ConsumerStatefulWidget {
  bool isGroup = true;

  FriendGroupScreen({super.key, this.isGroup = true});

  @override
  ConsumerState<FriendGroupScreen> createState() => _FriendGroupScreenState();
}

class _FriendGroupScreenState extends ConsumerState<FriendGroupScreen> {
  var addFriendTec = TextEditingController();
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<List<Group>> myGroupListFuture;
  late Future<List<Friend>> friendListFuture;

  Future<List<Group>> getMyGroup(String? jwtToken) async {
    var url = Uri.http(baseUri, '/group/getMyGroup');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    dynamic data;
    if (response.statusCode == 200) {
      print('getmygroupsuccess');
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      data = parsedJson.map((e) => Group.fromJson(e)).toList();
    } else {
      print('fail ${response.statusCode}');
    }
    return data;
  }

  void addFriend() async {
    var url = Uri.http(baseUri, '/friend/request/${addFriendTec.text}');
    var response =
        await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      print('친추 성공');
      Fluttertoast.showToast(msg: '친구 추가 요청을 보냈습니다');
    } else {
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: result['message']);
    }
    addFriendTec.text = "";
  }

  Future<List<Friend>> getFriendList() async {
    var url = Uri.http(baseUri, '/friend/getList');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Friend.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('친구목록 get 실패');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // jwtToken = ref.read(tokensProvider.notifier).state[0];
    jwtToken = Get.find<AutoLoginController>().state[0];
    print('Getjwt : ${Get.find<AutoLoginController>().state}');
    print('riverpodjwt : ${ref.read(tokensProvider.notifier).state}');
    myGroupListFuture = getMyGroup(jwtToken);
    friendListFuture = getFriendList();
    // setState(() {
    //   myGroupListFuture = getMyGroup(jwtToken);
    //   friendListFuture = getFriendList();
    // });
  }

  void emptyEmailToast() {
    Fluttertoast.showToast(msg: "이메일이 입력되지 않았습니다.");
  }

  friendView1() {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              bool? isBack = false;
              isBack = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendCheckScreen(),
                  ));
              print(isBack);
              if (isBack!) {
                setState(() {
                  friendListFuture = getFriendList();
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: const Row(children: [
                Icon(
                  Icons.call_received,
                  color: Color.fromARGB(108, 67, 182, 99),
                ),
                SizedBox(
                  width: 10,
                ),
                Text("친구 초대 관리"),
              ]),
            ),
          ),
          GestureDetector(
            onTap: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.question,
                body: Center(
                    child: Column(
                  children: [
                    const Text(
                      "친구 요청 보내기",
                      style: TextStyle(
                          color: Color.fromARGB(255, 60, 60, 69), fontSize: 22),
                    ),
                    TextField(
                      controller: addFriendTec,
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          hintText: "친구의 Email을 입력해주세요",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.email_rounded,
                            color: Colors.blue,
                          )),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ],
                )),
                btnOkOnPress: () async {
                  addFriend();
                },
                btnCancelOnPress: () {},
              ).show();
            },
            child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 40, 0),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_to_home_screen,
                      color: Color.fromARGB(108, 67, 182, 99),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("친구 추가")
                  ],
                )),
          ),
        ],
      ),
    );
  }

  friendView2() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: friendListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var friendList = snapshot.data;
              print(friendList);
              if (friendList!.isEmpty) {
                return const Center(child: Text('등록된 친구가 없습니다'));
              } else {
                return ListView.builder(
                    itemBuilder: (context, index) {
                      return friendComponent(friend: snapshot.data![index]);
                    },
                    itemCount: friendList.length);
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

  friendComponent({required Friend friend}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('${friend.friendName} 시간표'),
                ),
                body: TimeTableScreen(friendMemberId: friend.friendMemberId),
              ),
            ));
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 255, 255, 255),
              boxShadow: [
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
                            child: const Icon(Icons.person_4),
                          )),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(friend.friendName!,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
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
                              dialogType: DialogType.info,
                              title: "친구 정보",
                              desc:
                                  " 이름 : ${friend.friendName}\n Email: ${friend.friendEmail}",
                              btnOkOnPress: () {},
                            ).show();
                          },
                          icon: const Icon(Icons.info)),
                      IconButton(
                          onPressed: () {
                            AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    title: "친구 삭제",
                                    desc:
                                        "정말 ${friend.friendName}님과 친구를 끊으시겠습니까?",
                                    btnOkOnPress: () async {
                                      var url = Uri.http(baseUri,
                                          '/friend/delete/${friend.friendId}');
                                      var response = await http.delete(url,
                                          headers: {
                                            'authorization': 'Bearer $jwtToken'
                                          });
                                      if (response.statusCode == 200) {
                                        Fluttertoast.showToast(msg: '삭제되었습니다');
                                        setState(() {
                                          friendListFuture = getFriendList();
                                        });
                                      }
                                    },
                                    btnCancelOnPress: () {})
                                .show();
                          },
                          icon: const Icon(Icons.delete))
                    ]),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  groupView1() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvitationScreen(),
                    ));
              },
              child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.call_received,
                        color: Color.fromARGB(108, 84, 67, 182),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('그룹 초대 관리')
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategorySelectScreen(),
                    ));
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 30, 0),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_circle_sharp,
                      color: Color.fromARGB(108, 84, 67, 182),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("그룹 만들기")
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  groupView2() {
    return Expanded(
      child: Container(
        // padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.all(Radius.circular(30))),
        child: FutureBuilder(
          future: myGroupListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                print("data is present");
                return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return groupComponent(group: snapshot.data![index]);
                    });
              } else {
                print("no group..");
                return const Center(
                  child: Text('소속된 그룹이 없습니다'),
                );
              }
            } else {
              print("No data..!!");
              return const Center(child: Text('불러오는 중...'));
            }
          },
        ),
      ),
    );
  }

  groupComponent({required Group group}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailScreen(
                  groupId: group.groupId,
                ),
              )).then((value) {
            setState(() {
              myGroupListFuture = getMyGroup(jwtToken);
            });
          });
        },
        child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
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
                              child: const Icon(Icons.group),
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(group.groupName!,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500)),
                                    Text(group.amIOwner! ? "내 그룹" : "",
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500))
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(group.oneLineInfo!,
                                    style: TextStyle(color: Colors.grey[500])),
                              ]),
                        )
                      ]),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200),
                            child: Text(
                              group.categoryName!,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200),
                            child: Text(
                              group.categoryLabel!,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Text('${group.nowMember!} / ${group.maxMember!}'),
                    ],
                  ),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    print('친구그룹');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 244, 248),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isGroup = true;
                  });
                },
                child: Container(
                  height: 80,
                  // width: 200,
                  decoration: BoxDecoration(
                      color: widget.isGroup
                          ? Colors.blue
                          : const Color.fromARGB(255, 176, 220, 240),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "그룹",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
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
                    widget.isGroup = false;
                  });
                },
                child: Container(
                  height: 80,
                  // width: 200,
                  decoration: BoxDecoration(
                      color: widget.isGroup
                          ? const Color.fromARGB(255, 176, 220, 240)
                          : Colors.blue,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "친구",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
            ],
          ),
          widget.isGroup ? groupView1() : friendView1(),
          widget.isGroup ? groupView2() : friendView2(),
        ],
      ),
    );
  }
}
