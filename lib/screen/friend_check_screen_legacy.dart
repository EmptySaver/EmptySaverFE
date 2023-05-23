import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FriendCheckScreenOld extends ConsumerStatefulWidget {
  const FriendCheckScreenOld({super.key});

  @override
  ConsumerState<FriendCheckScreenOld> createState() =>
      _FriendCheckScreenState();
}

class _FriendCheckScreenState extends ConsumerState<FriendCheckScreenOld> {
  var baseUri = '43.201.208.100:8080';
  late var jwtToken;
  late Future<List<Friend>> requestFriendListFuture;
  late Future<List<Friend>> receiveFriendListFuture;

  Future<List<Friend>> getRequestFriendList() async {
    var url = Uri.http(baseUri, '/friend/requestList');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
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
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
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
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    requestFriendListFuture = getRequestFriendList();
    receiveFriendListFuture = getReceiveFriendList();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('받은 친구 요청'),
              const SizedBox(
                height: 10,
              ),
              Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(width: 1),
                  ),
                  clipBehavior: Clip.hardEdge,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FutureBuilder(
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return const Text('받은 요청이 없습니다');
                            } else {
                              return ListView.separated(
                                  itemBuilder: (context, index) => Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 200,
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            child: Center(
                                              child: Text(
                                                  '${snapshot.data![index].friendName}'),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          OutlinedButton(
                                              onPressed: () async {
                                                var url = Uri.http(baseUri,
                                                    '/friend/add/${snapshot.data![index].friendId}');
                                                var response = await http
                                                    .post(url, headers: {
                                                  'authorization':
                                                      'Bearer $jwtToken'
                                                });
                                                if (response.statusCode ==
                                                    200) {
                                                  Fluttertoast.showToast(
                                                      msg: '수락되었습니다');
                                                  setState(() {
                                                    receiveFriendListFuture =
                                                        getReceiveFriendList();
                                                  });
                                                } else {
                                                  print(utf8.decode(
                                                      response.bodyBytes));
                                                }
                                              },
                                              child: const Text('수락')),
                                          OutlinedButton(
                                              onPressed: () async {
                                                var url = Uri.http(baseUri,
                                                    '/friend/deny/${snapshot.data![index].friendId}');
                                                var response = await http
                                                    .delete(url, headers: {
                                                  'authorization':
                                                      'Bearer $jwtToken'
                                                });
                                                if (response.statusCode ==
                                                    200) {
                                                  Fluttertoast.showToast(
                                                      msg: '거절되었습니다');
                                                  setState(() {});
                                                } else {
                                                  print(utf8.decode(
                                                      response.bodyBytes));
                                                }
                                              },
                                              child: const Text('거절')),
                                        ],
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
                        future: receiveFriendListFuture),
                  )),
              const SizedBox(
                height: 30,
              ),
              const Text('보낸 친구 요청'),
              const SizedBox(
                height: 10,
              ),
              Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(width: 1),
                  ),
                  clipBehavior: Clip.hardEdge,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FutureBuilder(
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return const Text('보낸 요청이 없습니다');
                            } else {
                              return ListView.separated(
                                  itemBuilder: (context, index) => Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 200,
                                            decoration: BoxDecoration(
                                                border: Border.all()),
                                            child: Center(
                                              child: Text(
                                                  '${snapshot.data![index].friendName}'),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          OutlinedButton(
                                              onPressed: () {},
                                              child: const Text('aa')),
                                          OutlinedButton(
                                              onPressed: () {},
                                              child: const Text('bb')),
                                        ],
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
                        future: requestFriendListFuture),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
