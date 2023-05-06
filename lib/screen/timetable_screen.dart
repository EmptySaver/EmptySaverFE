import 'dart:convert';
import 'dart:math';
import 'package:emptysaver_fe/element/get_timetable_factory.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/add_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  var trueIndexLists = [];
  final random = Random();

  Future<ScheduleList> getSchedule(
      String? jwtToken, ScheduleList? scheduleList) async {
    {
      var url = Uri.http(baseUri, '/timetable/getTimeTable');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Bearer $jwtToken'
        },
        body: jsonEncode({"startDate": "2023-05-06", "endDate": "2023-05-06"}),
      );
      if (response.statusCode == 200) {
        print('getsuccess');
        var parsedJson = jsonDecode(response.body);
        scheduleList = ScheduleList.fromJson(parsedJson);
        print(scheduleList.scheduleListPerDays![0][0]['timeData']);
        var firstDayMap = scheduleList.scheduleListPerDays![0];
        for (int i = 0; i < firstDayMap.length; i++) {
          List<int> trueIndexList = [];
          for (int j = 16; j < 48; j++) {
            if (firstDayMap[i]['timeData'][j] == true) {
              trueIndexList.add(j - 16);
            }
          }
          trueIndexLists.add(trueIndexList);
        }
        print(trueIndexLists);
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
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    scheduleList = getSchedule(jwtToken, ScheduleList());
  }

  @override
  Widget build(BuildContext context) {
    print('있냐? : $scheduleList');
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
            ),
            itemCount: 1,
            itemBuilder: (context, index, big) {
              int realIndex = big - 10000;
              print('rebuildtimetable : $index, $big, $realIndex');
              return SingleChildScrollView(
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
                                  for (int i = 0;
                                      i < trueIndexLists.length;
                                      i++)
                                    Positioned(
                                      top: defaultBoxHeight *
                                          trueIndexLists[i][0],
                                      child: Container(
                                        height: defaultBoxHeight *
                                            (trueIndexLists[i].length),
                                        width: defaultBoxWidth,
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 1),
                                          color: Color.fromARGB(
                                            random.nextInt(256),
                                            random.nextInt(256),
                                            random.nextInt(256),
                                            random.nextInt(256),
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
                    child: const Icon(Icons.get_app),
                    label: '불러오기',
                    backgroundColor: Colors.green,
                    onTap: () {
                      getSchedule(jwtToken, ScheduleList());
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
