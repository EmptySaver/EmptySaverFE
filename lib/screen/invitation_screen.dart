import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class InvitationScreen extends ConsumerStatefulWidget {
  const InvitationScreen({super.key});

  @override
  ConsumerState<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<InvitationScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  Future<List<Group>>? memberReceiveListFuture;
  Future<List<Group>>? memberRequestListFuture;

  Future<List<Group>> getMemberReceiveList() async {
    var url = Uri.http(baseUri, '/group/getMemberReceiveList');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('받은 그룹 초대장 가져오기 실패');
    }
  }

  Future<List<Group>> getMemberRequestList() async {
    var url = Uri.http(baseUri, '/group/getMemberRequestList');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
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
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    memberReceiveListFuture = getMemberReceiveList();
    memberRequestListFuture = getMemberRequestList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('초대 받음'),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 300,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all()),
              width: double.infinity,
              child: FutureBuilder(
                future: memberReceiveListFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('받은 그룹 초대장이 없습니다'));
                    } else {
                      return ListView.separated(
                          itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GroupFinderDetailScreen(
                                          id: snapshot.data![index].groupId,
                                        ),
                                      ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                  ),
                                  height: 75,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.group_add,
                                          size: 50,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot
                                                .data![index].groupName!),
                                            // Text(snapshot.data![index].oneLineInfo!),
                                            Text(snapshot
                                                .data![index].categoryLabel!),
                                            Text(
                                                '${snapshot.data![index].nowMember!} / ${snapshot.data![index].maxMember!}'),
                                          ],
                                        ),
                                        OutlinedButton(
                                            onPressed: () async {
                                              var url = Uri.http(baseUri,
                                                  '/group/acceptInvite/${snapshot.data![index].groupId}');
                                              var response = await http.put(url,
                                                  headers: {
                                                    'authorization':
                                                        'Bearer $jwtToken'
                                                  });
                                              if (response.statusCode == 200) {
                                                Fluttertoast.showToast(
                                                    msg: '그룹에 가입되었습니다');
                                                setState(() {
                                                  memberReceiveListFuture =
                                                      getMemberReceiveList();
                                                });
                                              } else {
                                                print(utf8.decode(
                                                    response.bodyBytes));
                                                Fluttertoast.showToast(
                                                    msg: '가입 실패');
                                              }
                                            },
                                            child: const Text('가입')),
                                        OutlinedButton(
                                            onPressed: () async {
                                              var url = Uri.http(baseUri,
                                                  '/group/deleteMe/${snapshot.data![index].groupId}');
                                              var response = await http
                                                  .delete(url, headers: {
                                                'authorization':
                                                    'Bearer $jwtToken',
                                              });
                                              if (response.statusCode == 200) {
                                                Fluttertoast.showToast(
                                                    msg: '거절되었습니다');
                                                setState(() {
                                                  memberReceiveListFuture =
                                                      getMemberReceiveList();
                                                });
                                              } else {
                                                print(utf8.decode(
                                                    response.bodyBytes));
                                              }
                                            },
                                            child: const Text('거절')),
                                      ],
                                    ),
                                  ),
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
            const SizedBox(
              height: 30,
            ),
            const Text('보낸 가입 요청'),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 300,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all()),
              width: double.infinity,
              child: FutureBuilder(
                future: memberRequestListFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('보낸 그룹 가입 요청이 없습니다'));
                    } else {
                      return ListView.separated(
                          itemBuilder: (context, index) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GroupFinderDetailScreen(
                                          id: snapshot.data![index].groupId,
                                        ),
                                      ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.5),
                                  ),
                                  height: 75,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.group_add,
                                          size: 50,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(snapshot
                                                .data![index].groupName!),
                                            // Text(snapshot.data![index].oneLineInfo!),
                                            Text(snapshot
                                                .data![index].categoryLabel!),
                                            Text(
                                                '${snapshot.data![index].nowMember!} / ${snapshot.data![index].maxMember!}'),
                                          ],
                                        ),
                                        OutlinedButton(
                                            onPressed: () async {
                                              var url = Uri.http(baseUri,
                                                  '/group/deleteMe/${snapshot.data![index].groupId}');
                                              var response = await http
                                                  .delete(url, headers: {
                                                'authorization':
                                                    'Bearer $jwtToken',
                                              });
                                              if (response.statusCode == 200) {
                                                Fluttertoast.showToast(
                                                    msg: '취소되었습니다');
                                                setState(() {
                                                  memberRequestListFuture =
                                                      getMemberRequestList();
                                                });
                                              } else {
                                                print(utf8.decode(
                                                    response.bodyBytes));
                                              }
                                            },
                                            child: const Text('취소')),
                                      ],
                                    ),
                                  ),
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
            )
          ],
        ),
      ),
    );
  }
}
