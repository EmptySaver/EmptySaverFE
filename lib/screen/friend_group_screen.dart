import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/category_select_screen.dart';
import 'package:emptysaver_fe/screen/friend_check_screen.dart';
import 'package:emptysaver_fe/screen/group_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FriendGroupScreen extends ConsumerStatefulWidget {
  const FriendGroupScreen({super.key});

  @override
  ConsumerState<FriendGroupScreen> createState() => _FriendGroupScreenState();
}

class _FriendGroupScreenState extends ConsumerState<FriendGroupScreen> {
  var addFriendTec = TextEditingController();
  var baseUri = '43.201.208.100:8080';
  late var jwtToken;
  late Future<Unwrap> UnwrapData;
  late Future<List<Friend>> friendListFuture;

  Future<Unwrap> getMyGroup(String? jwtToken) async {
    var url = Uri.http(baseUri, '/group/getMyGroup');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    dynamic data;
    if (response.statusCode == 200) {
      print('getmygroupsuccess');
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
      data = Unwrap.fromJson(parsedJson);
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
      print(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: '요청 실패! 이메일을 확인하세요');
    }
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
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    UnwrapData = getMyGroup(jwtToken);
    friendListFuture = getFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '친구',
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                          onPressed: () async {
                            bool? isBack = false;
                            isBack = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FriendCheckScreen(),
                                ));
                            if (isBack!) {
                              setState(() {
                                friendListFuture = getFriendList();
                              });
                            }
                          },
                          child: const Text('조회')),
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
                                  title: const Text('친구 추가'),
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                          icon: Icon(Icons.person),
                                          hintText: '이메일 입력',
                                          labelText: 'e-mail'),
                                      controller: addFriendTec,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    OutlinedButton(
                                        onPressed: addFriend,
                                        child: const Text('추가하기'))
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('추가')),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              height: 250,
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: friendListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var friendList = snapshot.data;
                      print(friendList);
                      if (friendList!.isEmpty) {
                        return const Center(child: Text('등록된 친구가 없습니다'));
                      } else {
                        return ListView.separated(
                            itemBuilder: (context, index) {
                              return Container(
                                height: 40,
                                decoration: BoxDecoration(border: Border.all()),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Center(
                                        child: Text(
                                            '${friendList[index].friendName}')),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.remove_red_eye)),
                                        IconButton(
                                            onPressed: () async {
                                              var url = Uri.http(baseUri,
                                                  '/friend/delete/${friendList[index].friendId}');
                                              var response = await http
                                                  .delete(url, headers: {
                                                'authorization':
                                                    'Bearer $jwtToken'
                                              });
                                              if (response.statusCode == 200) {
                                                Fluttertoast.showToast(
                                                    msg: '삭제되었습니다');
                                                setState(() {
                                                  friendListFuture =
                                                      getFriendList();
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.remove_circle_outline)),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  height: 5,
                                ),
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
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('모임'),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategorySelectScreen(),
                        ));
                  },
                  child: const Text('생성'),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              height: 250,
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: UnwrapData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var groupList = snapshot.data!.data;
                      return ListView.separated(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () async {
                                var url = Uri.http(baseUri,
                                    '/group/delete/${groupList[index]['groupId']}');
                                var response = await http.delete(url, headers: {
                                  'authorization': 'Bearer $jwtToken'
                                });
                                if (response.statusCode == 200) {
                                  Fluttertoast.showToast(msg: '삭제되었습니다');
                                  setState(() {
                                    UnwrapData = getMyGroup(jwtToken);
                                  });
                                } else {
                                  Fluttertoast.showToast(msg: 'error!');
                                }
                              },
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupDetailScreen(
                                        groupData: groupList[index],
                                      ),
                                    ));
                              },
                              child: Container(
                                height: 40,
                                width: double.infinity,
                                decoration: BoxDecoration(border: Border.all()),
                                child: Center(
                                    child: Text(
                                  groupList![index]['groupName'],
                                  style: const TextStyle(fontSize: 25),
                                )),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 5,
                              ),
                          itemCount: snapshot.data!.data!.length);
                    } else {
                      return const Center(child: Text('불러오는 중...'));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
