import 'dart:convert';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/add_schedule_screen_new.dart';
import 'package:emptysaver_fe/screen/category_select_screen.dart';
import 'package:emptysaver_fe/screen/lecture_search_result_screen.dart';
import 'package:emptysaver_fe/screen/update_schedule_screen.dart';
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
  late Future<ScheduleList> memberScheduleFuture;
  late Future<GroupScheduleList> groupScheduleFuture;
  // ScheduleList? memberSchedule = ScheduleList();
  // ScheduleList? groupSchedule = ScheduleList();
  late var memberTrueIndexListsTotal;
  late var memberNameListsTotal;
  late var memberBodyListsTotal;
  late var memberIdListsTotal;
  late var groupTrueIndexListsTotal;
  late var groupNameListsTotal;
  late var groupBodyListsTotal;
  late var groupIdListsTotal;
  int pageIndex = 0;
  var searchTec = TextEditingController();

  Future<ScheduleList> getMemberSchedule() async {
    // getSchedule입니다
    {
      memberTrueIndexListsTotal = [];
      memberNameListsTotal = [];
      memberBodyListsTotal = [];
      memberIdListsTotal = [];
      late ScheduleList memberSchedule;
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
        var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
        // memberSchedule = ScheduleList.fromJson(parsedJson["memberTimeTable"]);
        memberSchedule = ScheduleList.fromJson(parsedJson);
        for (int h = 0; h < memberSchedule.scheduleListPerDays!.length; h++) {
          var trueIndexLists = [];
          var nameLists = [];
          var bodyLists = [];
          var idLists = [];
          var dayMap = memberSchedule.scheduleListPerDays![h];
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
          memberTrueIndexListsTotal.add(trueIndexLists);
          memberNameListsTotal.add(nameLists);
          memberBodyListsTotal.add(bodyLists);
          memberIdListsTotal.add(idLists);
        }
        // print('요일 전체 : $trueIndexListsTotal');
      } else {
        print('getfailmemberschedule');
        print(utf8.decode(response.bodyBytes));
      }
      return memberSchedule;
    }
  }

  Future<GroupScheduleList> getGroupSchedule() async {
    {
      groupTrueIndexListsTotal = [];
      groupNameListsTotal = [];
      groupBodyListsTotal = [];
      groupIdListsTotal = [];
      late GroupScheduleList groupSchedule;
      ScheduleList? timeTableInfo;
      var startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: pageIndex * 5, hours: 9)));
      var endDate = DateFormat('yyyy-MM-dd').format(
          DateTime.now().add(Duration(days: pageIndex * 5 + 4, hours: 9)));
      var url = Uri.http(baseUri, '/timetable/getMemberAndGroupTimeTable');
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
        var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
        groupSchedule =
            GroupScheduleList.fromJson(parsedJson["groupTimeTableList"]);
        timeTableInfo = groupSchedule.timeTableInfo;
        for (int h = 0; h < timeTableInfo!.scheduleListPerDays!.length; h++) {
          var trueIndexLists = [];
          var nameLists = [];
          var bodyLists = [];
          var idLists = [];
          var dayMap = timeTableInfo.scheduleListPerDays![h];
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
          groupTrueIndexListsTotal.add(trueIndexLists);
          groupNameListsTotal.add(nameLists);
          groupBodyListsTotal.add(bodyLists);
          groupIdListsTotal.add(idLists);
        }
        // print('요일 전체 : $trueIndexListsTotal');
      } else {
        print('getfailmemberschedule');
        print(utf8.decode(response.bodyBytes));
      }
      return groupSchedule;
    }
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
  }

  @override
  Widget build(BuildContext context) {
    memberScheduleFuture = getMemberSchedule();
    // groupScheduleFuture = getGroupSchedule();
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
                  // memberScheduleFuture = getMemberSchedule();
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
                            future: memberScheduleFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                // print(snapshot.data!.scheduleListPerDays!);
                                print(memberTrueIndexListsTotal);
                                if (snapshot
                                    .data!.scheduleListPerDays!.isEmpty) {
                                  return const defaultTimeTableFrame();
                                } else {
                                  return Stack(
                                    children: [
                                      const defaultTimeTableFrame(),
                                      for (int h = 0;
                                          h < memberTrueIndexListsTotal.length;
                                          h++)
                                        for (int i = 0;
                                            i <
                                                memberTrueIndexListsTotal[h]
                                                    .length;
                                            i++)
                                          Positioned(
                                            top: defaultBoxHeight *
                                                memberTrueIndexListsTotal[h][i]
                                                    [0],
                                            left: defaultBoxWidth * h,
                                            child: GestureDetector(
                                              onLongPress: () {
                                                print(memberIdListsTotal[h][i]);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    var lectureInfo = snapshot
                                                            .data!
                                                            .scheduleListPerDays![
                                                        h][i];
                                                    return SimpleDialog(
                                                      title:
                                                          const Text('스케줄 변경'),
                                                      children: [
                                                        !(lectureInfo[
                                                                    'groupType'] ==
                                                                true)
                                                            ? TextButton(
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                UpdateScheduleScreen(
                                                                          scheduleId:
                                                                              memberIdListsTotal[h][i],
                                                                          groupId:
                                                                              lectureInfo['groupId'],
                                                                        ),
                                                                      ));
                                                                },
                                                                child:
                                                                    const Text(
                                                                        '변경'))
                                                            : const Center(
                                                                child: Text(
                                                                  '그룹스케줄은 변경이 불가능합니다',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ),
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              var url = Uri.http(
                                                                  baseUri,
                                                                  '/timetable/deleteSchedule',
                                                                  {
                                                                    'scheduleId':
                                                                        '${memberIdListsTotal[h][i]}'
                                                                  });
                                                              var response =
                                                                  await http.delete(
                                                                      url,
                                                                      headers: {
                                                                    'authorization':
                                                                        'Bearer $jwtToken'
                                                                  });
                                                              if (response
                                                                      .statusCode ==
                                                                  200) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            '삭제되었습니다');
                                                                setState(() {});
                                                                Navigator.pop(
                                                                    context);
                                                              } else {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'error!');
                                                                print(utf8.decode(
                                                                    response
                                                                        .bodyBytes));
                                                              }
                                                            },
                                                            child: !(lectureInfo[
                                                                        'groupType'] ==
                                                                    true)
                                                                ? const Text(
                                                                    '삭제')
                                                                : const Text(
                                                                    '나에게서만 삭제')),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                height: defaultBoxHeight *
                                                    (memberTrueIndexListsTotal[
                                                            h][i]
                                                        .length),
                                                width: defaultBoxWidth,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black),
                                                  color: ((h + i) > 17)
                                                      ? Colors.primaries[
                                                          (h + i) % 17]
                                                      : Colors
                                                          .primaries[(h + i)],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(memberNameListsTotal[h]
                                                        [i]),
                                                    // Text(bodyListsTotal[h][i])
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                    ],
                                  );
                                }
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                          // FutureBuilder(
                          //   future: groupScheduleFuture,
                          //   builder: (context, snapshot) {
                          //     if (snapshot.hasData) {
                          //       print(snapshot
                          //           .data!.timeTableInfo!.scheduleListPerDays!);
                          //       print('그룹:$groupTrueIndexListsTotal');
                          //       if (snapshot.data!.timeTableInfo!
                          //           .scheduleListPerDays!.isEmpty) {
                          //         return const defaultTimeTableFrame();
                          //       } else {
                          //         return Stack(
                          //           children: [
                          //             const defaultTimeTableFrame(),
                          //             for (int h = 0;
                          //                 h < groupTrueIndexListsTotal.length;
                          //                 h++)
                          //               for (int i = 0;
                          //                   i <
                          //                       groupTrueIndexListsTotal[h]
                          //                           .length;
                          //                   i++)
                          //                 Positioned(
                          //                   top: defaultBoxHeight *
                          //                       groupTrueIndexListsTotal[h][i]
                          //                           [0],
                          //                   left: defaultBoxWidth * h,
                          //                   child: GestureDetector(
                          //                     onLongPress: () async {
                          //                       print(groupIdListsTotal[h][i]);
                          //                       var url = Uri.http(
                          //                           baseUri,
                          //                           '/timetable/deleteSchedule',
                          //                           {
                          //                             'scheduleId':
                          //                                 '${groupIdListsTotal[h][i]}'
                          //                           });
                          //                       var response = await http
                          //                           .delete(url, headers: {
                          //                         'authorization':
                          //                             'Bearer $jwtToken'
                          //                       });
                          //                       if (response.statusCode ==
                          //                           200) {
                          //                         Fluttertoast.showToast(
                          //                             msg: '삭제되었습니다');
                          //                         setState(() {});
                          //                       } else {
                          //                         Fluttertoast.showToast(
                          //                             msg: 'error!');
                          //                         print(utf8.decode(
                          //                             response.bodyBytes));
                          //                       }
                          //                     },
                          //                     child: Container(
                          //                       height: defaultBoxHeight *
                          //                           (groupTrueIndexListsTotal[h]
                          //                                   [i]
                          //                               .length),
                          //                       width: defaultBoxWidth,
                          //                       decoration: BoxDecoration(
                          //                         border: Border.all(
                          //                             width: 1,
                          //                             color: Colors.black),
                          //                         color: ((h + i) > 17)
                          //                             ? Colors.primaries[
                          //                                 (h + i) % 17]
                          //                             : Colors
                          //                                 .primaries[(h + i)],
                          //                       ),
                          //                       child: Column(
                          //                         mainAxisAlignment:
                          //                             MainAxisAlignment.center,
                          //                         children: [
                          //                           Text(groupNameListsTotal[h]
                          //                               [i]),
                          //                           // Text(bodyListsTotal[h][i])
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 )
                          //           ],
                          //         );
                          //       }
                          //     } else {
                          //       return const Center(
                          //         child: CircularProgressIndicator(),
                          //       );
                          //     }
                          //   },
                          // ),
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          contentPadding: const EdgeInsets.all(10),
                          title: const Text('강의 검색'),
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.search),
                                  hintText: '검색어를 입력하세요',
                                  labelText: '강의 검색'),
                              controller: searchTec,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            OutlinedButton(
                                onPressed: () async {
                                  var url = Uri.http(
                                    baseUri,
                                    '/subject/search',
                                  );
                                  var response = await http.post(url,
                                      headers: {
                                        'authorization': 'Bearer $jwtToken',
                                        'Content-Type': 'application/json'
                                      },
                                      body:
                                          jsonEncode({'name': searchTec.text}));
                                  if (response.statusCode == 200) {
                                    var parsedJson = jsonDecode(
                                            utf8.decode(response.bodyBytes))
                                        as List;
                                    List<Lecture> data = parsedJson
                                        .map((e) => Lecture.fromJson(e))
                                        .toList();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LectureSearchResultScreen(
                                                  resultList: data),
                                        ));
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                    Fluttertoast.showToast(msg: '검색 에러');
                                  }
                                },
                                child: const Text('찾기'))
                          ],
                        );
                      },
                    );
                  },
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
