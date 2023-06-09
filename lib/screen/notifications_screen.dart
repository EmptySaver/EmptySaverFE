import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  // _setAlertIcon(String routeValue, String type1, String type2, String title) {
  //   if (routeValue == "groupDetail" || routeValue == "post") {
  //     if (title.contains("댓글"))
  //       return Icon(CupertinoIcons.chat_bubble);
  //     else
  //       return Icon(CupertinoIcons.pencil_ellipsis_rectangle);
  //   } else if (routeValue == "friend") {
  //     return Icon(CupertinoIcons.person);
  //   } else if (routeValue == "group") {
  //     return Icon(CupertinoIcons.group);
  //   } else {
  //     if (type1 == "friend")
  //       return Icon(CupertinoIcons.person_add);
  //     else if (type1 == "group")
  //       return Icon(Icons.group_add_outlined);
  //     else if (type1 == "Schedule")
  //       return Icon(CupertinoIcons.clock);
  //     else
  //       return Icon(CupertinoIcons.info);
  //   }
  // }
  _setAlertIcon(String routeValue, String type1, String type2, String title) {
    if (routeValue == "groupDetail" || routeValue == "post") {
      return Icon(
        CupertinoIcons.chat_bubble,
        color: Colors.amber,
      );
    } else if (routeValue == "friend") {
      return Icon(
        CupertinoIcons.person,
        color: Colors.green,
      );
    } else if (routeValue == "group") {
      return Icon(
        CupertinoIcons.person_2,
        color: Colors.lightBlue,
      );
    } else {
      if (type1 == "friend")
        return Icon(
          CupertinoIcons.person,
          color: Colors.green,
        );
      else if (type1 == "group")
        return Icon(
          CupertinoIcons.person_2,
          color: Colors.lightBlue,
        );
      else if (type1 == "Schedule")
        return Icon(
          CupertinoIcons.person_2,
          color: Colors.lightBlue,
        );
      else
        return Icon(CupertinoIcons.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('알림 리빌드');
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림함'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder(
              future: notiListFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var notiList = snapshot.data!.reversed.toList();
                  if (notiList.isNotEmpty) {
                    return Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: notiList.length,
                          itemBuilder: (context, index) {
                            String routeValue = notiList[index].routeValue!;
                            String? idType = notiList[index].idType!;
                            String? idType2 = notiList[index].idType2!;
                            int? idValue = notiList[index].idValue!;
                            int? idValue2 = notiList[index].idValue2!;
                            bool? isRead = notiList[index].isRead;
                            return GestureDetector(
                              onTap: () async {
                                if (isRead == false) {
                                  var url = Uri.http(baseUri,
                                      '/notification/check/${notiList[index].id}');
                                  var response = await http.put(url, headers: {
                                    'authorization': 'Bearer $jwtToken'
                                  });
                                  if (response.statusCode == 200) {
                                    print('알림 읽음');
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                  }
                                }
                                setState(() {
                                  notiListFuture = getAllNotification();
                                  routeSwitching(routeValue,
                                      idType: idType,
                                      idType2: idType2,
                                      idValue: idValue,
                                      idValue2: idValue2);
                                });
                              },
                              child: Container(
                                // padding: const EdgeInsets.all(5),
                                // margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                decoration: BoxDecoration(
                                  color: (isRead == true)
                                      ? Colors.blueGrey.withAlpha(30)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // const Icon(
                                    //   Icons.messenger_outline,
                                    //   size: 30,
                                    // ),
                                    _setAlertIcon(routeValue, idType, idType2,
                                        notiList[index].title!),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Text(
                                            '${notiList[index].title}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('${notiList[index].body}'),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              '${notiList[index].receiveTime}'),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  } else {
                    return Center(
                      child: const Text('알림이 없습니다'),
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
        ],
      ),
    );
  }

  Future<List<Noti>> getAllNotification() async {
    var url = Uri.http(baseUri, '/notification/getAll');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
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
