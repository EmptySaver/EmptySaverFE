import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/add_group_schedule_screen.dart';
import 'package:emptysaver_fe/screen/group_check_screen.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:emptysaver_fe/screen/update_group_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class GroupDetailScreen extends ConsumerStatefulWidget {
  Map<String, dynamic>? groupData;

  GroupDetailScreen({super.key, this.groupData});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  late Future<List<Map<String, dynamic>>> groupMemberFuture;
  late Future<List<ScheduleText>> groupScheduleTextListFuture;
  var memberIdTec = TextEditingController();

  Future<List<Map<String, dynamic>>> getGroupMember() async {
    var url = Uri.http(
        baseUri, '/group/getGroupMember/${widget.groupData!['groupId']}');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData
          .map((e) => {'memberId': e['memberId'], 'name': e['name']})
          .toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('그룹멤버 가져오기 실패');
    }
  }

  Future<List<ScheduleText>> getGroupScheduleTextList() async {
    var url = Uri.http(baseUri, '/timetable/team/getScheduleList',
        {'groupId': '${widget.groupData!['groupId']}'});
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
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
        headers: {
          'authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'memberId': memberIdTec.text,
          'groupId': widget.groupData!['groupId']
        }));
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '초대를 보냈습니다');
      Navigator.pop(context);
    } else {
      print(utf8.decode(response.bodyBytes));
    }
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    groupMemberFuture = getGroupMember();
    groupScheduleTextListFuture = getGroupScheduleTextList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 상세'),
        actions: [
          IconButton(
              onPressed: () async {
                var url = Uri.http(
                    baseUri, '/group/deleteMe/${widget.groupData!['groupId']}');
                var response = await http.delete(url, headers: {
                  'authorization': 'Bearer $jwtToken',
                });
                if (response.statusCode == 200) {
                  Fluttertoast.showToast(msg: '탈퇴되었습니다');
                } else {
                  print(utf8.decode(response.bodyBytes));
                }
              },
              icon: const Icon(Icons.outbond_outlined)),
          IconButton(
              onPressed: () async {
                var url = Uri.http(
                    baseUri, '/group/delete/${widget.groupData!['groupId']}');
                var response = await http.delete(url, headers: {
                  'authorization': 'Bearer $jwtToken',
                });
                if (response.statusCode == 200) {
                  Fluttertoast.showToast(msg: '그룹이 삭제되었습니다');
                  Navigator.pop(context, '');
                } else {
                  print(utf8.decode(response.bodyBytes));
                }
              },
              icon: const Icon(Icons.delete_forever_outlined))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                      widget.groupData!['groupName'],
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupCheckScreen(
                                  groupId: widget.groupData!['groupId']),
                            ));
                      },
                      child: const Text('조회'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('공지사항'),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 150,
                  width: 350,
                  decoration: BoxDecoration(border: Border.all()),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('일정 목록'),
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddGroupScheduleScreen(
                                  groupData: widget.groupData),
                            )).then((value) => setState(
                              () {
                                groupScheduleTextListFuture =
                                    getGroupScheduleTextList();
                              },
                            ));
                        //                     if (isBack) {
                        //                       setState(() {
                        // groupScheduleTextListFuture = getGroupScheduleTextList();

                        //                       });
                        //                     }
                      },
                      child: const Text('추가'), // 그룹장이 아니면 안보이게
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 150,
                  width: 350,
                  decoration: BoxDecoration(border: Border.all()),
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
                                                      builder: (context) =>
                                                          UpdateGroupScheduleScreen(
                                                        groupData:
                                                            widget.groupData,
                                                        scheduleId: snapshot
                                                            .data![index].id,
                                                      ),
                                                    )).then((value) => setState(
                                                      () {
                                                        groupScheduleTextListFuture =
                                                            getGroupScheduleTextList();
                                                      },
                                                    ));
                                              },
                                              child: const Text('변경')),
                                          TextButton(
                                              onPressed: () async {
                                                var url = Uri.http(
                                                    baseUri,
                                                    '/timetable/team/deleteSchedule',
                                                    {
                                                      'groupId':
                                                          '${widget.groupData!['groupId']}',
                                                      'scheduleId':
                                                          '${snapshot.data![index].id}'
                                                    });
                                                var response = await http
                                                    .delete(url, headers: {
                                                  'authorization':
                                                      'Bearer $jwtToken'
                                                });
                                                if (response.statusCode ==
                                                    200) {
                                                  Fluttertoast.showToast(
                                                      msg: '삭제되었습니다');
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    groupScheduleTextListFuture =
                                                        getGroupScheduleTextList();
                                                  });
                                                } else {
                                                  print(utf8.decode(
                                                      response.bodyBytes));
                                                }
                                              },
                                              child: const Text('삭제')),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  height: 60,
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: Column(
                                    children: [
                                      Text('${snapshot.data![index].name}'),
                                      Text('${snapshot.data![index].body}'),
                                      Text('${snapshot.data![index].timeData}'),
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
                    const Text('구성원 목록'),
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              contentPadding: const EdgeInsets.all(10),
                              title: const Text('그룹에 초대'),
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.person),
                                      hintText: '멤버 id를 입력하세요',
                                      labelText: 'Member ID'),
                                  controller: memberIdTec,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                OutlinedButton(
                                    onPressed: sendInvite,
                                    child: const Text('초대하기'))
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('초대'),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(5),
                  height: 180,
                  width: 350,
                  decoration: BoxDecoration(border: Border.all()),
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
                                    decoration:
                                        BoxDecoration(border: Border.all()),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            'id:${snapshot.data![index]['memberId']} ${snapshot.data![index]['name']}'),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                          appBar: AppBar(
                                                            title: Text(
                                                                '${snapshot.data![index]['name']} 시간표 조회'),
                                                          ),
                                                          body: TimeTableScreen(
                                                            groupMemberId:
                                                                snapshot.data![
                                                                        index][
                                                                    'memberId'],
                                                          ),
                                                        ),
                                                      ));
                                                },
                                                icon: const Icon(
                                                    Icons.remove_red_eye)),
                                            IconButton(
                                                onPressed: () async {
                                                  var url = Uri.http(baseUri,
                                                      '/group/deleteMember');
                                                  var response =
                                                      await http.delete(url,
                                                          headers: {
                                                            'authorization':
                                                                'Bearer $jwtToken',
                                                            'Content-Type':
                                                                'application/json; charset=UTF-8'
                                                          },
                                                          body: jsonEncode({
                                                            'memberId': snapshot
                                                                        .data![
                                                                    index]
                                                                ['memberId'],
                                                            'groupId': widget
                                                                    .groupData![
                                                                'groupId']
                                                          }));
                                                  if (response.statusCode ==
                                                      200) {
                                                    Fluttertoast.showToast(
                                                        msg: '삭제되었습니다');
                                                    setState(() {
                                                      groupMemberFuture =
                                                          getGroupMember();
                                                    });
                                                  }
                                                },
                                                icon: const Icon(Icons
                                                    .remove_circle_outline)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
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
    );
  }
}
