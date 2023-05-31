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
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    recommendedScheduleListFuture = getRecommendedSchedule(isChecked);
  }

  var startDate = '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(hours: 9)))}T00:00:00';
  var endDate = '${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7, hours: 9)))}T00:00:00';
  late Future<List<ScheduleInfo>> recommendedScheduleListFuture;
  Future<List<ScheduleInfo>> getRecommendedSchedule(bool interest) async {
    var url = Uri.http(baseUri, '/timetable/recommendSchedule', {'interestFilterOn': '$isChecked'});
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
    print('re');
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
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey.shade200),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('추천목록'),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 24),
                              child: Checkbox(
                                value: isChecked,
                                onChanged: (value) {
                                  isChecked = !isChecked;
                                  setState(() {
                                    recommendedScheduleListFuture = getRecommendedSchedule(isChecked);
                                  });
                                },
                              ),
                            ),
                            const Text('관심사 적용'),
                            const SizedBox(
                              width: 30,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FutureBuilder(
                          future: recommendedScheduleListFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.separated(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var eachCategory = snapshot.data![index].category;
                                    return Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blueAccent),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(children: [
                                        Text('${snapshot.data![index].name}'),
                                        Text('${snapshot.data![index].body}'),
                                        (eachCategory != null) ? Text(eachCategory) : const Text('카테고리 없음'),
                                        Text('${snapshot.data![index].timeData}'),
                                      ]),
                                    );
                                  },
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
