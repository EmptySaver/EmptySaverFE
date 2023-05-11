import 'dart:convert';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/add_schedule_screen.dart';
import 'package:emptysaver_fe/screen/category_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

const double defaultBoxWidth = 75;
const double defaultBoxHeight = 35;

class TimeTableScreen extends ConsumerStatefulWidget {
  const TimeTableScreen({super.key});

  @override
  ConsumerState<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends ConsumerState<TimeTableScreen> {
  var baseUri = '43.201.208.100:8080';
  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();
  late var jwtToken;
  late Future<ScheduleList> scheduleList;
  ScheduleList? scheduleListFrame = ScheduleList();
  late var trueIndexListsTotal;
  late var nameListsTotal;
  late var bodyListsTotal;
  late var idListsTotal;
  int pageIndex = 0;

  Future<ScheduleList> getSchedule(
      String? jwtToken, ScheduleList? scheduleList) async {
    {
      var startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: pageIndex * 5, hours: 9)));
      var endDate = DateFormat('yyyy-MM-dd').format(
          DateTime.now().add(Duration(days: pageIndex * 5 + 4, hours: 9)));
      var url = Uri.http(baseUri, '/timetable/getTimeTable');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode({"startDate": startDate, "endDate": endDate}),
      );
      if (response.statusCode == 200) {
        print('getsuccess');
        print('$startDate  $endDate');
        var parsedJson = jsonDecode(response.body);
        scheduleList = ScheduleList.fromJson(parsedJson);
        for (int h = 0; h < scheduleList.scheduleListPerDays!.length; h++) {
          var trueIndexLists = [];
          var nameLists = [];
          var bodyLists = [];
          var idLists = [];
          var dayMap = scheduleList.scheduleListPerDays![h];
          for (int i = 0; i < dayMap.length; i++) {
            List<int> trueIndexList = [];
            for (int j = 16; j < 48; j++) {
              // print(dayMap[i]['timeData']);
              if (dayMap[i]['timeData'][j] == true) {
                trueIndexList.add(j - 16);
              }
            }
            trueIndexLists.add(trueIndexList);
            nameLists.add(dayMap[i]['name']);
            bodyLists.add(dayMap[i]['body']);
            idLists.add(dayMap[i]['id']);
          }
          // print('요일 하나 : $trueIndexLists');
          trueIndexListsTotal.add(trueIndexLists);
          nameListsTotal.add(nameLists);
          bodyListsTotal.add(bodyLists);
          idListsTotal.add(idLists);
        }
        // print('요일 전체 : $trueIndexListsTotal');
      } else {
        print('getfail');
        print(response.statusCode);
      }
      return scheduleList!;
    }
  }

  @override
  void initState() {
    super.initState();
    trueIndexListsTotal = [];
    nameListsTotal = [];
    bodyListsTotal = [];
    idListsTotal = [];
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    scheduleList = getSchedule(jwtToken, scheduleListFrame);
  }

  @override
  Widget build(BuildContext context) {
    trueIndexListsTotal = [];
    nameListsTotal = [];
    bodyListsTotal = [];
    idListsTotal = [];
    scheduleList = getSchedule(jwtToken, scheduleListFrame);
    var colorIndex = -1;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: CarouselSlider.builder(
            options: CarouselOptions(
              enableInfiniteScroll: true,
              initialPage: 0,
              height: 700,
              viewportFraction: 1,
              // onScrolled: (value) {
              //   print(value);
              // },
              onPageChanged: (index, reason) {
                pageIndex = (index > 499)
                    ? index - 999
                    : index; //pageIndex(위젯 전체) == realIndex(빌더 안)
                print(pageIndex);
                setState(() {});
              },
            ),
            itemCount: 999,
            itemBuilder: (context, index, big) {
              int realIndex = big - 10000;
              print('rebuildtimetable : $index, $big, $realIndex');
              return RefreshIndicator(
                onRefresh: () async {
                  scheduleList = getSchedule(jwtToken, scheduleListFrame);
                  setState(() {});
                },
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: Row(children: [
                      Column(children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                        ),
                        for (int i = 1; i < 17; i++)
                          TimeHeaderBox(timeText: i + 7),
                      ]),
                      Column(
                        children: [
                          Row(
                            children: [
                              for (int i = 0; i < 5; i++)
                                DefaultHeaderBox(
                                  nowDate: '${DateFormat('E', 'ko').format(
                                    DateTime.now().add(
                                      Duration(
                                        days: (i - 5 + (realIndex + 1) * 5),
                                        hours: 9,
                                      ),
                                    ),
                                  )} ${DateFormat('Md').format(DateTime.now().add(Duration(days: (i - 5 + (realIndex + 1) * 5), hours: 9)))}',
                                )
                            ],
                          ),
                          FutureBuilder(
                            future: scheduleList,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Stack(
                                  children: [
                                    const defaultTimeTableFrame(),
                                    for (int h = 0;
                                        h < trueIndexListsTotal.length;
                                        h++)
                                      for (int i = 0;
                                          i < trueIndexListsTotal[h].length;
                                          i++)
                                        Positioned(
                                          top: defaultBoxHeight *
                                              trueIndexListsTotal[h][i][0],
                                          left: defaultBoxWidth * h,
                                          child: GestureDetector(
                                            onLongPress: () async {
                                              print(idListsTotal[h][i]);
                                              var url = Uri.http(baseUri,
                                                  '/timetable/deleteSchedule', {
                                                'scheduleId':
                                                    '${idListsTotal[h][i]}'
                                              });
                                              var response = await http
                                                  .post(url, headers: {
                                                'authorization':
                                                    'Bearer $jwtToken'
                                              });
                                              if (response.statusCode == 200) {
                                                Fluttertoast.showToast(
                                                    msg: '삭제되었습니다');
                                                setState(() {});
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: 'error!');
                                              }
                                            },
                                            child: Container(
                                              height: defaultBoxHeight *
                                                  (trueIndexListsTotal[h][i]
                                                      .length),
                                              width: defaultBoxWidth,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black),
                                                color: ((h + i) > 17)
                                                    ? Colors
                                                        .primaries[(h + i) % 17]
                                                    : Colors.primaries[(h + i)],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(nameListsTotal[h][i]),
                                                  // Text(bodyListsTotal[h][i])
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                  ],
                                );
                              }
                              return const defaultTimeTableFrame();
                            },
                          ),
                        ],
                      )
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SpeedDial(
              icon: Icons.add,
              backgroundColor: Colors.blueGrey,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.schedule),
                  label: '일정 추가',
                  backgroundColor: Colors.red,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddScheduleScreen(),
                        ));
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.class_outlined),
                  label: '강의 추가',
                  backgroundColor: Colors.blue,
                  onTap: () {},
                ),
                SpeedDialChild(
                    child: const Icon(Icons.group_add),
                    label: '그룹 생성',
                    backgroundColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategorySelectScreen(),
                          ));
                    }),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class defaultTimeTableFrame extends StatelessWidget {
  const defaultTimeTableFrame({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Column(
            children: [for (int j = 0; j < 32; j++) defaultBox(tag: j)],
          ),
      ],
    );
  }
}

class defaultBox extends StatelessWidget {
  defaultBox({
    super.key,
    required this.tag,
  });

  final int tag;
  bool isFill = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: defaultBoxWidth,
      height: defaultBoxHeight,
      decoration: BoxDecoration(
        color: isFill ? Colors.black : Colors.white,
        border: Border(
          left: const BorderSide(color: Colors.blueGrey, width: 0.2),
          right: const BorderSide(color: Colors.blueGrey, width: 0.2),
          bottom: (tag % 2 == 1)
              ? const BorderSide(color: Colors.blueGrey, width: 0.2)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class TimeHeaderBox extends StatelessWidget {
  late int timeText;
  TimeHeaderBox({
    super.key,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 0.2),
      ),
      child: Text(
        '$timeText',
        textAlign: TextAlign.end,
      ),
    );
  }
}

class DefaultHeaderBox extends StatelessWidget {
  late String nowDate;
  DefaultHeaderBox({
    super.key,
    required this.nowDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 0.2),
      ),
      child: Center(child: Text(nowDate)),
    );
  }
}
