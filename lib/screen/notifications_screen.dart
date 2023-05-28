import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<List<Noti>> notiListFuture;

  @override
  void initState() {
    super.initState();
    notiListFuture = getAllNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림함'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: notiListFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var notiList = snapshot.data!.reversed.toList();
                  if (notiList.isNotEmpty) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: notiList.length,
                        itemBuilder: (context, index) {
                          String routeValue = notiList[index].routeValue!;
                          String? idType = notiList[index].idType!;
                          String? idType2 = notiList[index].idType2!;
                          int? idValue = notiList[index].idValue!;
                          int? idValue2 = notiList[index].idValue2!;
                          return GestureDetector(
                            onTap: () async {
                              routeSwitching(routeValue, idType: idType, idType2: idType2, idValue: idValue, idValue2: idValue2);
                              var url = Uri.http(baseUri, '/notification/check/${notiList[index].id}');
                              var response = await http.put(url, headers: {'authorization': 'Bearer $jwtToken'});
                              if (response.statusCode == 200) {
                                print('알림 읽음');
                              } else {
                                print(utf8.decode(response.bodyBytes));
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(width: 1)),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Icon(
                                    Icons.message,
                                    size: 45,
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${notiList[index].title}'),
                                        Text('${notiList[index].body}'),
                                        Text('${notiList[index].receiveTime}'),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    return const Text('알림이 없습니다');
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
      ),
    );
  }

  Future<List<Noti>> getAllNotification() async {
    var url = Uri.http(baseUri, '/notification/getAll');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = decodedJson.map((e) => Noti.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('알림 리스트 받아오기 실패');
    }
  }
}
