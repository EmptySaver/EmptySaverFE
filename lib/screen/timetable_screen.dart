import 'dart:convert';
import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/screen/add_schedule_screen_new.dart';
import 'package:emptysaver_fe/screen/category_select_screen.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:emptysaver_fe/screen/lecture_search_result_screen.dart';
import 'package:emptysaver_fe/screen/recommend_schedule_screen.dart';
import 'package:emptysaver_fe/screen/today_movie_screen.dart';
import 'package:emptysaver_fe/screen/update_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

const double defaultBoxWidth = 73;
const double defaultBoxHeight = 35;

class TimeTableScreen extends ConsumerStatefulWidget {
  int? friendMemberId;
  int? groupMemberId;

  TimeTableScreen({super.key, this.friendMemberId, this.groupMemberId});

  @override
  ConsumerState<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends ConsumerState<TimeTableScreen> {
  var baseUri = '43.201.208.100:8080';
  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();
  var jwtToken = AutoLoginController.to.state[0];
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
  late double bodyWidth, bodyHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    memberScheduleFuture = getMemberSchedule();
    // groupScheduleFuture = getGroupSchedule();
    var colorIndex = -1;
    return LayoutBuilder(
      builder: (context, constraints) {
        bodyWidth = constraints.maxWidth;
        bodyHeight = constraints.maxHeight;
        print('가로 : $bodyWidth, 세로 : $bodyHeight');
        return SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    enableInfiniteScroll: true,
                    initialPage: 0,
                    height: bodyHeight,
                    viewportFraction: 1,
                    // onScrolled: (value) {
                    //   print(value);
                    // },
                    onPageChanged: (index, reason) {
                      pageIndex = (index > 499) ? index - 999 : index; //pageIndex(위젯 전체) == realIndex(빌더 안)
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
                          width: 388,
                          // height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            Column(children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                              ),
                              for (int i = 1; i < 17; i++) TimeHeaderBox(timeText: i + 7),
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
                                            ),
                                          ),
                                        )} ${DateFormat('Md').format(DateTime.now().add(Duration(
                                          days: (i - 5 + (realIndex + 1) * 5),
                                        )))}',
                                      )
                                  ],
                                ),
                                FutureBuilder(
                                  future: memberScheduleFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      // print(snapshot.data!.scheduleListPerDays!);
                                      print(memberTrueIndexListsTotal);
                                      if (snapshot.data!.scheduleListPerDays!.isEmpty) {
                                        return const defaultTimeTableFrame();
                                      } else {
                                        return Stack(
                                          children: [
                                            const defaultTimeTableFrame(),
                                            for (int h = 0; h < memberTrueIndexListsTotal.length; h++)
                                              for (int i = 0; i < memberTrueIndexListsTotal[h].length; i++)
                                                Positioned(
                                                  top: defaultBoxHeight * memberTrueIndexListsTotal[h][i][0],
                                                  left: defaultBoxWidth * h,
                                                  child: GestureDetector(
                                                    onLongPress: () {
                                                      print(memberIdListsTotal[h][i]);
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          var lectureInfo = snapshot.data!.scheduleListPerDays![h][i];
                                                          return SimpleDialog(
                                                            title: const Text('스케줄 변경'),
                                                            children: [
                                                              !(lectureInfo['groupType'] == true)
                                                                  ? TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => UpdateScheduleScreen(
                                                                                scheduleId: memberIdListsTotal[h][i],
                                                                                name: memberNameListsTotal[h][i],
                                                                                body: memberBodyListsTotal[h][i],
                                                                                groupId: lectureInfo['groupId'],
                                                                              ),
                                                                            )).then((value) {
                                                                          setState(() {
                                                                            memberScheduleFuture = getMemberSchedule();
                                                                          });
                                                                        });
                                                                      },
                                                                      child: const Text('변경'))
                                                                  : const Center(
                                                                      child: Text(
                                                                        '그룹스케줄은 변경이 불가능합니다',
                                                                        style: TextStyle(color: Colors.grey),
                                                                      ),
                                                                    ),
                                                              TextButton(
                                                                  onPressed: () async {
                                                                    var url = Uri.http(baseUri, '/timetable/deleteSchedule', {'scheduleId': '${memberIdListsTotal[h][i]}'});
                                                                    var response = await http.delete(url, headers: {'authorization': 'Bearer $jwtToken'});
                                                                    if (response.statusCode == 200) {
                                                                      Fluttertoast.showToast(msg: '삭제되었습니다');
                                                                      setState(() {});
                                                                      Navigator.pop(context);
                                                                    } else {
                                                                      Fluttertoast.showToast(msg: 'error!');
                                                                      print(utf8.decode(response.bodyBytes));
                                                                    }
                                                                  },
                                                                  child: !(lectureInfo['groupType'] == true) ? const Text('삭제') : const Text('나에게서만 삭제')),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      height: defaultBoxHeight * (memberTrueIndexListsTotal[h][i].length),
                                                      width: defaultBoxWidth,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(width: 1, color: Colors.black),
                                                        color: ((h + i) > 17) ? Colors.primaries[(h + i) % 17] : Colors.primaries[(h + i)],
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Center(child: Text(memberNameListsTotal[h][i] ?? 'null')),
                                                          ],
                                                        ),
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
                              )).then((value) {
                            setState(() {
                              memberScheduleFuture = getMemberSchedule();
                            });
                          });
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.class_outlined),
                        label: '강의 추가',
                        backgroundColor: Colors.blue,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LectureSearchResultScreen(),
                              ));
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
                      SpeedDialChild(
                        child: const Icon(Icons.search),
                        label: '스케줄 찾기',
                        backgroundColor: Colors.yellow,
                        onTap: findSchedule,
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.movie_creation_outlined),
                        label: '오늘 영화',
                        backgroundColor: Colors.deepPurple.shade100,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const TodayMovieScreen(),
                              )).then((value) {
                            setState(() {
                              memberScheduleFuture = getMemberSchedule();
                            });
                          });
                        },
                      ),
                      SpeedDialChild(
                        child: const Icon(Icons.recommend_outlined),
                        label: '스케줄 추천',
                        backgroundColor: Colors.teal,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const RecommendScheduleScreen(),
                              )).then((value) {
                            setState(() {
                              memberScheduleFuture = getMemberSchedule();
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<ScheduleList> getMemberSchedule() async {
    // getSchedule입니다
    {
      memberTrueIndexListsTotal = [];
      memberNameListsTotal = [];
      memberBodyListsTotal = [];
      memberIdListsTotal = [];
      late ScheduleList memberSchedule;
      var startDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: pageIndex * 5)));
      var endDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: pageIndex * 5 + 4)));
      Uri url;
      (widget.friendMemberId == null)
          ? (widget.groupMemberId == null)
              ? url = Uri.http(baseUri, '/timetable/getTimeTable')
              : url = Uri.http(baseUri, '/group/getMemberTimeTable', {'groupMemberId': '${widget.groupMemberId}'})
          : url = Uri.http(baseUri, '/friend/getFriendTimeTable', {
              'friendMemberId': '${widget.friendMemberId}',
            });
      http.Response response;
      response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json', 'authorization': 'Bearer $jwtToken'},
        body: jsonEncode({"startDate": startDate, "endDate": endDate}),
      );

      if (response.statusCode == 200) {
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
        print(memberNameListsTotal);
        print(memberBodyListsTotal);
        print(memberIdListsTotal);
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
      var startDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: pageIndex * 5)));
      var endDate = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: pageIndex * 5 + 4)));
      var url = Uri.http(baseUri, '/timetable/getMemberAndGroupTimeTable');
      var response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json', 'authorization': 'Bearer $jwtToken'},
        body: jsonEncode({"startDate": startDate, "endDate": endDate}),
      );
      if (response.statusCode == 200) {
        print('$startDate  $endDate');
        var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
        groupSchedule = GroupScheduleList.fromJson(parsedJson["groupTimeTableList"]);
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

  var findScheduleStartTec = TextEditingController();
  var findScheduleEndTec = TextEditingController();
  var findScheduleTec = TextEditingController();
  bool isSearched = false;
  late List<ScheduleInfo> scheduleInfoList;

  void findSchedule() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.all(8),
              children: [
                TextField(
                  controller: findScheduleStartTec,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_month_outlined),
                    labelText: '시작시간',
                  ),
                  keyboardType: TextInputType.none,
                  readOnly: true,
                ),
                TextField(
                  controller: findScheduleEndTec,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_month_outlined),
                    labelText: '종료시간',
                  ),
                  keyboardType: TextInputType.none,
                  readOnly: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                    onPressed: () async {
                      List<DateTime>? dates = await showOmniDateTimeRangePicker(
                        context: context,
                        is24HourMode: true,
                        isForce2Digits: true,
                        minutesInterval: 30,
                        startInitialDate: DateTime.now(),
                        endInitialDate: DateTime.now(),
                      );
                      if (dates != null) {
                        setState(() {
                          findScheduleStartTec.text = DateFormat('yyyy-MM-ddTHH:mm').format(dates[0]);
                          findScheduleEndTec.text = DateFormat('yyyy-MM-ddTHH:mm').format(dates[1]);
                        });
                      }
                    },
                    child: const Text('시간 선택')),
                OutlinedButton(
                    onPressed: () async {
                      if (findScheduleStartTec.text == '' || findScheduleEndTec.text == '') {
                        Fluttertoast.showToast(msg: '시간을 선택해주세요');
                        return;
                      }
                      var url = Uri.http(baseUri, '/timetable/findSchedule');
                      var response = await http.post(url,
                          headers: {
                            'authorization': 'Bearer $jwtToken',
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode({
                            'startTime': findScheduleStartTec.text,
                            'endTime': findScheduleEndTec.text,
                          }));
                      if (response.statusCode == 200) {
                        isSearched = true;
                        setState(
                          () {
                            var decodedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
                            scheduleInfoList = decodedJson.map((e) => ScheduleInfo.fromJson(e)).toList();
                          },
                        );
                      } else {
                        print(utf8.decode(response.bodyBytes));
                      }
                    },
                    child: const Text('공개 스케줄 검색')),
                const SizedBox(
                  height: 20,
                ),
                if (isSearched)
                  SizedBox(
                    height: 500,
                    width: 400,
                    child: ListView.builder(
                      itemCount: scheduleInfoList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupFinderDetailScreen(id: scheduleInfoList[index].groupInfo!.groupId),
                                ));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Text(
                                      scheduleInfoList[index].groupInfo!.groupName!,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    Text(scheduleInfoList[index].name!),
                                    Text(scheduleInfoList[index].body!),
                                    Text('${scheduleInfoList[index].category} - ${scheduleInfoList[index].subCategory}'),
                                    Text(scheduleInfoList[index].timeData!),
                                  ],
                                ),
                              ),
                              const Divider(
                                thickness: 1.2,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
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
          bottom: (tag % 2 == 1) ? const BorderSide(color: Colors.blueGrey, width: 0.2) : BorderSide.none,
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
      width: 73,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 0.2),
      ),
      child: Center(child: Text(nowDate)),
    );
  }
}
