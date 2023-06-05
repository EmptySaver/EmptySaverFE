import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TodayMovieScreen extends StatefulWidget {
  const TodayMovieScreen({super.key});

  @override
  State<TodayMovieScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<TodayMovieScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<List<ScheduleText>> todayMovieListFuture;

  @override
  void initState() {
    super.initState();
    todayMovieListFuture = getTodayMovie();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘 영화'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: FutureBuilder(
            future: todayMovieListFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var todayMovieList = snapshot.data!;
                return ListView.builder(
                  itemCount: todayMovieList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Column(
                        children: [
                          Text(
                            '${todayMovieList[index].name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          Text('${todayMovieList[index].timeData}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                  onPressed: () async {
                                    var url = Uri.parse('${todayMovieList[index].body}');
                                    if (await canLaunchUrl(url)) {
                                      launchUrl(url, mode: LaunchMode.externalApplication);
                                    } else {
                                      throw Exception('링크 열기 실패');
                                    }
                                  },
                                  child: const Text('정보 보기')),
                              const SizedBox(
                                width: 20,
                              ),
                              OutlinedButton(
                                  onPressed: () async {
                                    print(todayMovieList[index].id);
                                    var url = Uri.http(baseUri, '/timetable/saveScheduleByCopy', {'scheduleId': '${todayMovieList[index].id}'});
                                    var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(msg: '추가되었습니다');
                                      Navigator.pop(context, '');
                                    } else {
                                      print(utf8.decode(response.bodyBytes));
                                    }
                                  },
                                  child: const Text('시간표에 추가')),
                            ],
                          ),
                          const Divider(
                            thickness: 1.2,
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ))
        ],
      ),
    );
  }

  Future<List<ScheduleText>> getTodayMovie() async {
    var url = Uri.http(baseUri, '/timetable/getMovieScheduleList');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var data = (jsonDecode(utf8.decode(response.bodyBytes)) as List).map((e) => ScheduleText.fromJson(e)).toList();
      print(data);
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('오늘 영화 불러오기 실패');
    }
  }
}
