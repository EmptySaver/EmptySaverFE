import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/screen/add_group_schedule_screen.dart';
import 'package:emptysaver_fe/screen/each_post_screen.dart';
import 'package:emptysaver_fe/screen/group_check_screen.dart';
import 'package:emptysaver_fe/screen/make_post_screen.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:emptysaver_fe/screen/update_group_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class GroupDetailScreen extends ConsumerStatefulWidget {
  int? groupId;

  GroupDetailScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  Group groupData = Group();
  late Future<List<Map<String, dynamic>>> groupMemberFuture;
  late Future<List<ScheduleText>> groupScheduleTextListFuture;
  late Future<List<dynamic>> groupPostListFuture;
  var memberIdTec = TextEditingController();
  bool amIOwner = false;
  // void waitForGroupData() async {
  //   groupData = await getGroupDetail();
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    getGroupDetail().then((value) {
      groupData = value;
      amIOwner = groupData.amIOwner!;
      setState(() {});
    });
    // waitForGroupData();
    groupMemberFuture = getGroupMember();
    groupScheduleTextListFuture = getGroupScheduleTextList();
    groupPostListFuture = getPostList();
  }

  @override
  Widget build(BuildContext context) {
    print('그룹디테일');
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 상세'),
        actions: [
          IconButton(
              onPressed: () {
                showMenu(context: context, position: const RelativeRect.fromLTRB(1, 0, 0, 0), items: <PopupMenuEntry>[
                  if (amIOwner)
                    const PopupMenuItem(
                      value: 0,
                      child: Text('그룹 삭제'),
                    ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text('그룹 탈퇴'),
                  ),
                ]).then((value) {
                  if (value == 0) {
                    deleteGroup(context);
                  } else if (value == 1) {
                    withdrawalGroup();
                  }
                });
              },
              icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 350,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${groupData.groupName}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        visible: amIOwner,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupCheckScreen(groupId: widget.groupId),
                                ));
                          },
                          child: const Text('조회'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '공지사항',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Visibility(
                        visible: amIOwner,
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MakePostScreen(
                                      groupdata: groupData,
                                    ),
                                  )).then((value) => setState(
                                    () {
                                      groupPostListFuture = getPostList();
                                    },
                                  ));
                            },
                            child: const Text('글쓰기')),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 200,
                    width: 350,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FutureBuilder(
                      future: groupPostListFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isNotEmpty) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var postId = snapshot.data![index]['postId'];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EachPostScreen(
                                            postId: postId,
                                            groupId: widget.groupId,
                                          ),
                                        ));
                                  },
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(
                                          contentPadding: const EdgeInsets.all(8),
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => EachPostScreen(
                                                          mode: 'write',
                                                          postId: snapshot.data![index]['postId'],
                                                        ),
                                                      )).then((value) => setState(
                                                        () {
                                                          groupPostListFuture = getPostList();
                                                        },
                                                      ));
                                                },
                                                child: const Text('수정')),
                                            TextButton(
                                                onPressed: () async {
                                                  var url = Uri.http(baseUri, '/board/deletePost/${snapshot.data![index]['postId']}');
                                                  var response = await http.delete(url, headers: {'authorization': 'Bearer $jwtToken'});
                                                  if (response.statusCode == 200) {
                                                    Fluttertoast.showToast(msg: '삭제되었습니다');
                                                    setState(() {
                                                      groupPostListFuture = getPostList();
                                                    });
                                                    Navigator.pop(context);
                                                  } else {
                                                    print(utf8.decode(response.bodyBytes));
                                                    return;
                                                  }
                                                },
                                                child: const Text('삭제'))
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    height: 60,
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
                                    child: Center(
                                      child: Text(
                                        '${snapshot.data![index]['title']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('등록된 공지사항이 없습니다'),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '일정 목록',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Visibility(
                        visible: amIOwner,
                        child: OutlinedButton(
                          onPressed: addGroupSchedule,
                          child: const Text('추가'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    // clipBehavior: Clip.hardEdge,
                    height: 250,
                    width: 350,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FutureBuilder(
                      future: groupScheduleTextListFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Center(child: Text('등록된 일정이 없습니다'));
                          } else {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(
                                          title: const Text('그룹 일정 변경'),
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => UpdateGroupScheduleScreen(
                                                          groupData: groupData,
                                                          scheduleId: snapshot.data![index].id,
                                                        ),
                                                      )).then((value) => setState(
                                                        () {
                                                          groupScheduleTextListFuture = getGroupScheduleTextList();
                                                        },
                                                      ));
                                                },
                                                child: const Text('변경')),
                                            TextButton(
                                                onPressed: () async {
                                                  var url = Uri.http(baseUri, '/timetable/team/deleteSchedule', {'groupId': '${widget.groupId}', 'scheduleId': '${snapshot.data![index].id}'});
                                                  var response = await http.delete(url, headers: {'authorization': 'Bearer $jwtToken'});
                                                  if (response.statusCode == 200) {
                                                    Fluttertoast.showToast(msg: '삭제되었습니다');
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      groupScheduleTextListFuture = getGroupScheduleTextList();
                                                    });
                                                  } else {
                                                    print(utf8.decode(response.bodyBytes));
                                                  }
                                                },
                                                child: const Text('삭제')),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 100,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      // border: const Border(bottom: BorderSide(style: BorderStyle.none)),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      color: (snapshot.data![index].read!) ? Colors.grey.shade200 : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${snapshot.data![index].name}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                        Text('${snapshot.data![index].body}'),
                                        Text('${snapshot.data![index].timeData}'),
                                        Visibility(
                                          visible: !amIOwner,
                                          child: Visibility(
                                            visible: !snapshot.data![index].read!,
                                            child: ButtonBar(
                                              buttonPadding: EdgeInsets.zero,
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () {
                                                    okSchedule(snapshot.data![index].id, true);
                                                  },
                                                  icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.greenAccent,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () {
                                                    okSchedule(snapshot.data![index].id, false);
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    color: Colors.redAccent,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '구성원 목록',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Visibility(
                        visible: amIOwner,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  contentPadding: const EdgeInsets.all(10),
                                  title: const Text('그룹에 초대'),
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(icon: Icon(Icons.person), hintText: '멤버 id를 입력하세요', labelText: 'Member ID'),
                                      controller: memberIdTec,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    OutlinedButton(onPressed: sendInvite, child: const Text('초대하기'))
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('초대'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(5),
                    height: 250,
                    width: 350,
                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                    child: FutureBuilder(
                      future: groupMemberFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return const Text('멤버가 없습니다');
                          } else {
                            return ListView.separated(
                                itemBuilder: (context, index) => Container(
                                      height: 40,
                                      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'id:${snapshot.data![index]['memberId']} ${snapshot.data![index]['name']}',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              Visibility(
                                                visible: amIOwner,
                                                child: IconButton(
                                                    onPressed: () {
                                                      changeOwner(snapshot.data![index]['memberId']);
                                                    },
                                                    icon: const Icon(
                                                      Icons.upgrade_rounded,
                                                      color: Colors.teal,
                                                    )),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => Scaffold(
                                                            appBar: AppBar(
                                                              title: Text('${snapshot.data![index]['name']} 시간표 조회'),
                                                            ),
                                                            body: TimeTableScreen(
                                                              groupMemberId: snapshot.data![index]['memberId'],
                                                            ),
                                                          ),
                                                        ));
                                                  },
                                                  icon: const Icon(
                                                    Icons.schedule,
                                                    color: Colors.blueAccent,
                                                  )),
                                              IconButton(
                                                  onPressed: () async {
                                                    var url = Uri.http(baseUri, '/group/deleteMember');
                                                    var response = await http.delete(url,
                                                        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                        body: jsonEncode({'memberId': snapshot.data![index]['memberId'], 'groupId': widget.groupId}));
                                                    if (response.statusCode == 200) {
                                                      Fluttertoast.showToast(msg: '삭제되었습니다');
                                                      setState(() {
                                                        groupMemberFuture = getGroupMember();
                                                      });
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    color: Colors.redAccent,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                separatorBuilder: (context, index) => const SizedBox(
                                      height: 5,
                                    ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void deleteGroup(BuildContext context) async {
    var url = Uri.http(baseUri, '/group/delete/${widget.groupId}');
    var response = await http.delete(url, headers: {
      'authorization': 'Bearer $jwtToken',
    });
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '그룹이 삭제되었습니다');
      Navigator.pop(context, '');
    } else {
      print(utf8.decode(response.bodyBytes));
    }
  }

  void withdrawalGroup() async {
    var url = Uri.http(baseUri, '/group/deleteMe/${widget.groupId}');
    var response = await http.delete(url, headers: {
      'authorization': 'Bearer $jwtToken',
    });
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '탈퇴되었습니다');
      Navigator.pop(context);
    } else {
      print(utf8.decode(response.bodyBytes));
    }
  }

  Future<Group> getGroupDetail() async {
    var url = Uri.http(baseUri, '/group/getGroupDetail/${widget.groupId}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var data = Group.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('그룹 디테일정보 가져오기 실패');
    }
  }

  Future<List<Map<String, dynamic>>> getGroupMember() async {
    var url = Uri.http(baseUri, '/group/getGroupMember/${widget.groupId}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => {'memberId': e['memberId'], 'name': e['name']}).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('그룹멤버 가져오기 실패');
    }
  }

  Future<List<ScheduleText>> getGroupScheduleTextList() async {
    var url = Uri.http(baseUri, '/timetable/team/getScheduleList', {'groupId': '${widget.groupId}'});
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = parsedJson.map((e) => ScheduleText.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('일정목록 가져오기 실패');
    }
  }

  void sendInvite() async {
    var url = Uri.http(baseUri, '/group/sendInvite');
    var response = await http.post(url,
        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode({'memberId': memberIdTec.text, 'groupId': widget.groupId}));
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '초대를 보냈습니다');
      Navigator.pop(context);
    } else {
      print(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: jsonDecode(utf8.decode(response.bodyBytes))['message']);
    }
  }

  Future<List<dynamic>> getPostList() async {
    var url = Uri.http(baseUri, '/board/getPostList/${widget.groupId}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('공지사항 가져오기 실패');
    }
  }

  void addGroupSchedule() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddGroupScheduleScreen(groupData: groupData),
        )).then((value) => setState(
          () {
            groupScheduleTextListFuture = getGroupScheduleTextList();
          },
        ));
  }

  void changeOwner(int? id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('그룹장을 변경하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () async {
                var url = Uri.http(baseUri, '/group/changeOwner');
                var response = await http.put(url,
                    headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'}, body: jsonEncode({'memberId': id, 'groupId': widget.groupId}));
                if (response.statusCode == 200) {
                  print(utf8.decode(response.bodyBytes));
                  setState(() {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                } else {
                  print(utf8.decode(response.bodyBytes));
                }
              },
              child: const Text('확인')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'))
        ],
      ),
    );
  }

  void okSchedule(int? memberId, bool? accept) async {
    var url = Uri.http(baseUri, '/timetable/team/readSchedule', {'scheduleId': '$memberId', 'accept': '$accept'});
    var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '스케줄을 처리했습니다');
      setState(() {
        groupScheduleTextListFuture = getGroupScheduleTextList();
      });
    } else {
      print(utf8.decode(response.bodyBytes));
    }
  }
}
