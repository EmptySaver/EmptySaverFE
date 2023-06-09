import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:time_range_picker/time_range_picker.dart';

class UpdateScheduleScreen extends StatefulWidget {
  int? scheduleId;
  int? groupId;
  String? name;
  String? body;

  UpdateScheduleScreen({super.key, this.scheduleId, this.groupId, this.name, this.body});

  @override
  State<UpdateScheduleScreen> createState() => _UpdateScheduleScreenState();
}

class _UpdateScheduleScreenState extends State<UpdateScheduleScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  final List<bool> _selections = List.generate(2, (_) => false);
  bool isPeriodic = false;
  bool isChecked = false;
  var nameTec = TextEditingController(text: '');
  var bodyTec = TextEditingController(text: '');
  bool isAdded = false;
  String? startTime;
  String? endTime;
  String dateInfo = "일정을 선택해주세요";
  String timeInfo = "시간을 선택해주세요";
  String perTimeInfo = "시간 선택";
  List<String> items = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];
  String? selectedValue;
  TimeOfDay? startDayTime;
  TimeOfDay? endDayTime;
  bool isSelectPlan = false;
  List<Item> itemList = [];
  DateTime? nonDate;
  TimeOfDay? nonPeriodicStartTime;
  TimeOfDay? nonPeriodicEndTime;

  @override
  void initState() {
    super.initState();
    nameTec.text = widget.name!;
    bodyTec.text = widget.body!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            '일정 변경',
          ),
        ),
        body: _buildPageContent(context),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          const Image(
            image: AssetImage('assets/logoVer2.png'),
            width: 250,
            height: 150,
            color: Colors.blueAccent,
          ),
          // const SizedBox(
          //   height: 30.0,
          // ),
          // const CircleAvatar(
          //   maxRadius: 50,
          //   backgroundColor: Colors.transparent,
          //   child: PNetworkImage(origami),
          // ),
          // const SizedBox(
          //   height: 20.0,
          // ),
          _buildAddScheduleForm(context),
        ],
      ),
    );
  }

  Container _buildAddScheduleForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          Container(
            //height: 700,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(40.0)), border: Border.all(color: Colors.blueAccent)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: nameTec,
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          hintText: "일정 제목",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.school,
                            color: Colors.blue,
                          )),
                      keyboardType: TextInputType.name,
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: bodyTec,
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          hintText: "간단한 내용",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.textsms,
                            color: Colors.blue,
                          )),
                      keyboardType: TextInputType.text,
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ToggleButtons(
                    isSelected: _selections,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("이번에만 할래요"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("매주 할래요"),
                      )
                    ],
                    onPressed: (index) async {
                      isChecked = true;
                      for (int i = 0; i < _selections.length; i++) {
                        _selections[i] = (i == index);
                      }
                      if (index == 0) {
                        isPeriodic = false;
                        print(isPeriodic);
                      } else {
                        isPeriodic = true;
                        print(isPeriodic);
                      }
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                Visibility(
                    visible: isChecked && !isPeriodic,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () async {
                                DateTime currentTime = await NTP.now();
                                currentTime = currentTime.toUtc().add(const Duration(hours: 9));
                                DateTime? result = await showRoundedDatePicker(context: context, initialDate: DateTime.now(), borderRadius: 16, locale: const Locale('ko', 'KR'));
                                if (result != null) {
                                  setState(() {
                                    nonDate = result;
                                    print("nonDate: ${nonDate.toString()}");
                                    dateInfo = "${nonDate!.year}년 ${nonDate!.month}월 ${nonDate!.day}일";
                                  });
                                }
                              },
                            ),
                            TextButton(
                                onPressed: () async {
                                  DateTime currentTime = await NTP.now();
                                  currentTime = currentTime.toUtc().add(const Duration(hours: 9));
                                  DateTime? result = await showRoundedDatePicker(context: context, initialDate: DateTime.now(), borderRadius: 16, locale: const Locale('ko', 'KR'));
                                  if (result != null) {
                                    setState(() {
                                      nonDate = result;
                                      print("nonDate: ${nonDate.toString()}");
                                      dateInfo = "${nonDate!.year}년 ${nonDate!.month}월 ${nonDate!.day}일";
                                    });
                                  }
                                },
                                child: Text(dateInfo))
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.timer),
                              onPressed: () async {
                                TimeRange? result = await showTimeRangePicker(
                                    context: context,
                                    interval: const Duration(minutes: 30),
                                    disabledTime: TimeRange(startTime: const TimeOfDay(hour: 0, minute: 0), endTime: const TimeOfDay(hour: 8, minute: 0)),
                                    start: const TimeOfDay(hour: 12, minute: 0),
                                    end: const TimeOfDay(hour: 15, minute: 0));
                                if (result != null) {
                                  setState(() {
                                    if ((result.startTime.hour > result.endTime.hour)) {
                                      Fluttertoast.showToast(msg: '종료 시간이 시작 시간보다 앞설 수 없습니다');
                                      return;
                                    }
                                    nonPeriodicStartTime = result.startTime;
                                    nonPeriodicEndTime = result.endTime;
                                    timeInfo = '${nonPeriodicStartTime!.hour}시 ${nonPeriodicStartTime!.minute}분 ~ ${nonPeriodicEndTime!.hour}시 ${nonPeriodicEndTime!.minute}분';
                                  });
                                }
                              },
                            ),
                            TextButton(
                                onPressed: () async {
                                  TimeRange? result = await showTimeRangePicker(
                                      context: context,
                                      interval: const Duration(minutes: 30),
                                      disabledTime: TimeRange(startTime: const TimeOfDay(hour: 0, minute: 0), endTime: const TimeOfDay(hour: 8, minute: 0)),
                                      start: const TimeOfDay(hour: 12, minute: 0),
                                      end: const TimeOfDay(hour: 15, minute: 0));
                                  if (result != null) {
                                    setState(() {
                                      if ((result.startTime.hour > result.endTime.hour)) {
                                        Fluttertoast.showToast(msg: '종료 시간이 시작 시간보다 앞설 수 없습니다');
                                        return;
                                      }
                                      nonPeriodicStartTime = result.startTime;
                                      nonPeriodicEndTime = result.endTime;
                                      timeInfo = '${nonPeriodicStartTime!.hour}시 ${nonPeriodicStartTime!.minute}분 ~ ${nonPeriodicEndTime!.hour}시 ${nonPeriodicEndTime!.minute}분';
                                    });
                                  }
                                },
                                child: Text(timeInfo))
                          ],
                        )
                      ],
                    )),
                Visibility(
                    visible: isPeriodic,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: const Row(
                                children: [
                                  Icon(
                                    Icons.list,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '요일 선택',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: items
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              value: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value as String;
                                  if (startDayTime != null && endDayTime != null) isSelectPlan = true;
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                width: 120,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.black26,
                                  ),
                                  color: const Color.fromARGB(255, 73, 190, 244),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                ),
                                iconSize: 14,
                                iconEnabledColor: Color.fromARGB(255, 255, 255, 255),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 200,
                                  padding: null,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.blueAccent,
                                  ),
                                  elevation: 8,
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility: MaterialStateProperty.all(true),
                                  )),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                          width: 200,
                          height: 40,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                padding: const EdgeInsets.only(left: 14, right: 14)),
                            onPressed: () async {
                              TimeRange? result = await showTimeRangePicker(
                                  context: context,
                                  interval: const Duration(minutes: 30),
                                  disabledTime: TimeRange(startTime: const TimeOfDay(hour: 0, minute: 0), endTime: const TimeOfDay(hour: 8, minute: 0)),
                                  start: const TimeOfDay(hour: 12, minute: 0),
                                  end: const TimeOfDay(hour: 15, minute: 0));

                              if (result != null) {
                                startDayTime = result.startTime;
                                endDayTime = result.endTime;
                                setState(() {
                                  if ((result.startTime.hour > result.endTime.hour)) {
                                    Fluttertoast.showToast(msg: '종료 시간이 시작 시간보다 앞설 수 없습니다');
                                    return;
                                  }
                                  startDayTime = result.startTime;
                                  endDayTime = result.endTime;
                                  perTimeInfo = '${startDayTime!.hour}시 ${startDayTime!.minute}분 ~ ${endDayTime!.hour}시 ${endDayTime!.minute}분';
                                  if (selectedValue != null) {
                                    isSelectPlan = true;
                                  }
                                });
                              }
                            },
                            child: Text(
                              perTimeInfo,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                    visible: isSelectPlan && isPeriodic,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AbsorbPointer(
                          absorbing: true,
                          child: Text(
                            "설정된 일시 :  $selectedValue요일 ${startDayTime?.hour}시 ${startDayTime?.minute}분 ~ ${endDayTime?.hour}시 ${endDayTime?.minute}분",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue),
                          ),
                        ),
                        OutlinedButton(
                            onPressed: () {
                              setState(() {
                                itemList.add(Item(day: selectedValue, startDayInfo: startDayTime, endDayInfo: endDayTime));
                                isSelectPlan = false;
                                startDayTime = endDayTime = null;
                                selectedValue = null;
                                perTimeInfo = "";
                              });
                            },
                            child: const Text("추가"))
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                Visibility(
                    visible: isPeriodic,
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "추가된 일시",
                        style: TextStyle(fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )),
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                    visible: isPeriodic,
                    child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2.0, spreadRadius: 1.0)],
                        ),
                        child: SizedBox(
                          height: 200,
                          child: ListView.builder(
                              padding: const EdgeInsets.all(6),
                              itemCount: itemList.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (itemList.isEmpty) {
                                  return const Text("추가된 일정이 없습니다");
                                }
                                Item item = itemList[index];
                                return Card(
                                  elevation: 3,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)), side: BorderSide(color: Colors.blueAccent)),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text("${item.day}요일 ${item.startDayInfo!.hour}시 ${item.startDayInfo!.minute}분 ~ ${item.endDayInfo!.hour}시 ${item.endDayInfo!.minute}분"),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                                              padding: const EdgeInsets.all(5),
                                              side: const BorderSide(
                                                color: Colors.cyan,
                                              )),
                                          onPressed: () {},
                                          child: const Text("삭제")),
                                    ),
                                  ]),
                                );
                              }),
                        ))),
                Row(
                  children: [
                    Switch(
                      activeColor: Colors.blueAccent,
                      value: switchValue,
                      onChanged: (value) {
                        setState(() {
                          switchValue = value;
                        });
                      },
                    ),
                    const Text('친구에게 스케줄 보이기'),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  //height: 380,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: OutlinedButton(
                      onPressed: () {
                        registerSchedule(context);
                      },
                      child: const Text("변경하기"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(0.0, -30),
                child: CircleAvatar(
                  radius: 35.0,
                  backgroundColor: Colors.blue.shade600,
                  child: const Icon(Icons.calendar_month),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool switchValue = false;
  void registerSchedule(BuildContext context) async {
    if (!isChecked) {
      Fluttertoast.showToast(msg: '일정 타입을 선택해주세요');
      return;
    }
    if (nameTec.text.isEmpty) {
      Fluttertoast.showToast(msg: '일정 제목을 입력해주세요');
      return;
    }
    if (bodyTec.text.isEmpty) {
      Fluttertoast.showToast(msg: '내용을 입력해주세요');
      return;
    }

    Map<String, Object> postBody;
    if (isPeriodic) {
      if (itemList.isEmpty) {
        Fluttertoast.showToast(msg: '일시를 1개 이상 추가해야 합니다.');
        return;
      } else {
        List<String> periodicList = [];
        for (var element in itemList) {
          String target = "${element.day},${element.startDayInfo!.hour}:${element.startDayInfo!.minute}-${element.endDayInfo!.hour}:${element.endDayInfo!.minute}";
          print(target);
          periodicList.add(target);
        }
        postBody = {
          'name': nameTec.text,
          'body': bodyTec.text,
          'periodicType': isPeriodic,
          'periodicTimeStringList': periodicList,
          'hideType': switchValue,
        };
        print(postBody);
      }
    } else {
      print(nonDate.toString());
      if (nonDate == null) {
        print("it is null");
        Fluttertoast.showToast(msg: '날짜를 선택해주세요');
        return;
      }
      if (nonPeriodicStartTime == null) {
        Fluttertoast.showToast(msg: '시간을 선택해주세요');
        return;
      }
      print(nonDate.toString().split(" ")[0]);
      print(nonPeriodicStartTime);
      dynamic startHour = nonPeriodicStartTime!.hour;
      var startMin = nonPeriodicStartTime!.minute.toString();
      if (startHour < 10) {
        startHour = '0$startHour';
      }
      if (startMin == "0") startMin = "00";
      dynamic endHour = nonPeriodicEndTime!.hour;
      if (endHour < 10) {
        endHour = '0$endHour';
      }
      var endMin = nonPeriodicEndTime!.minute.toString();
      if (endMin == "0") endMin = "00";
      postBody = {
        'name': nameTec.text,
        'body': bodyTec.text,
        'periodicType': isPeriodic,
        'startTime': "${nonDate.toString().split(" ")[0]}T$startHour:$startMin:00",
        'endTime': "${nonDate.toString().split(" ")[0]}T$endHour:$endMin:00",
        'hideType': switchValue,
      };
    }
    print(postBody);
    var url = Uri.http(baseUri, '/timetable/updateSchedule', {'scheduleId': '${widget.scheduleId}'});
    var response = await http.put(url, headers: <String, String>{'Content-Type': 'application/json', 'authorization': 'Bearer $jwtToken'}, body: jsonEncode(postBody));
    if (response.statusCode == 200) {
      print(response.body);
      Fluttertoast.showToast(msg: '변경되었습니다');
      Navigator.pop(context, '');
    } else {
      print(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: '변경 실패, 입력을 확인하세요');
    }
  }
}

class Item {
  final String? day;
  final TimeOfDay? startDayInfo;
  final TimeOfDay? endDayInfo;

  Item({this.day, this.startDayInfo, this.endDayInfo});
}
