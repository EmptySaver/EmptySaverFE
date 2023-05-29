import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/screen/add_group_screen_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:intl/intl.dart';

class CategorySelectScreen extends ConsumerStatefulWidget {
  const CategorySelectScreen({super.key});

  @override
  ConsumerState<CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends ConsumerState<CategorySelectScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];

  @override
  void initState() {
    super.initState();
    recommendedScheduleListFuture = getRecommendedSchedule();
  }

  var startDate = '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(hours: 9)))}T00:00:00';
  var endDate = '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7, hours: 9)))}T00:00:00';
  late Future<List<ScheduleInfo>> recommendedScheduleListFuture;
  Future<List<ScheduleInfo>> getRecommendedSchedule() async {
    var url = Uri.http(baseUri, '/timetable/recommendSchedule', {'interestFilterOn': 'false'});
    var response = await http.post(url,
        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
          {'startTime': startDate, 'endTime': endDate},
        ));
    if (response.statusCode == 200) {
      var decodedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = decodedJson.map((e) => ScheduleInfo.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('추천스케줄 불러오기 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 50,
              ),
              OutlinedButton(
                onPressed: () async {
                  var url = Uri.http(baseUri, '/category/getCategoryList');
                  var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
                  print(jsonDecode(utf8.decode(response.bodyBytes)));
                  var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
                  Category category = Category.fromJson(parsedJson);
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Center(
                        child: Text('카테고리'),
                      ),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: category.data!
                              .map((e) => TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddGroupScreen(
                                            type: e['type'],
                                            name: e['name'],
                                          ),
                                        ));
                                  },
                                  child: Text(e['name'])))
                              .toList(),
                        )
                      ],
                    ),
                  );
                },
                child: const Text('카테고리 고르기'),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('추천목록'),
                        const SizedBox(
                          height: 20,
                        ),
                        FutureBuilder(
                          future: recommendedScheduleListFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.separated(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) => Container(
                                        height: 90,
                                        decoration: BoxDecoration(border: Border.all(width: 1)),
                                        child: Column(children: [Text('${snapshot.data![index].name}'), Text('${snapshot.data![index].body}')]),
                                      ),
                                  separatorBuilder: (context, index) => const SizedBox(
                                        height: 5,
                                      ),
                                  itemCount: snapshot.data!.length);
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
