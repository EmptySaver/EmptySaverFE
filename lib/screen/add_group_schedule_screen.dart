import 'dart:convert';

import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddGroupScheduleScreen extends ConsumerStatefulWidget {
  Map<String, dynamic>? groupData;

  AddGroupScheduleScreen({super.key, this.groupData});

  @override
  ConsumerState<AddGroupScheduleScreen> createState() =>
      _AddGroupScheduleScreenState();
}

class _AddGroupScheduleScreenState
    extends ConsumerState<AddGroupScheduleScreen> {
  var baseUri = '43.201.208.100:8080';

  final List<bool> _selections = List.generate(2, (_) => false);
  bool isPeriodic = false;
  var dateTec = TextEditingController(text: '');
  var nameTec = TextEditingController(text: '');
  var bodyTec = TextEditingController(text: '');
  var daysTec1 = TextEditingController();
  var daysTec2 = TextEditingController();
  var timeTec1 = TextEditingController();
  var timeTec2 = TextEditingController();
  var timeTec3 = TextEditingController();
  var timeTec4 = TextEditingController();
  bool isAdded = false;
  String? startTime;
  String? endTime;
  List<DropdownMenuEntry<String>> days = [
    const DropdownMenuEntry(value: '월', label: '월'),
    const DropdownMenuEntry(value: '화', label: '화'),
    const DropdownMenuEntry(value: '수', label: '수'),
    const DropdownMenuEntry(value: '목', label: '목'),
    const DropdownMenuEntry(value: '금', label: '금'),
    const DropdownMenuEntry(value: '토', label: '토'),
    const DropdownMenuEntry(value: '일', label: '일'),
  ];

  @override
  Widget build(BuildContext context) {
    var jwtToken = ref.read(tokensProvider.notifier).state[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 일정 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: GestureDetector(
            // behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  ToggleButtons(
                    isSelected: _selections,
                    children: const [
                      Text('비주기적'),
                      Text('주기적'),
                    ],
                    onPressed: (index) async {
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
                  const SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    visible: !isPeriodic,
                    child: TextField(
                        controller: dateTec,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_month_outlined),
                          labelText: '날짜 선택',
                        ),
                        onTap: () async {
                          {
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2024));

                            if (pickeddate != null) {
                              setState(() {
                                dateTec.text =
                                    DateFormat('yyyy-MM-dd').format(pickeddate);
                              });
                            }
                          }
                        }),
                  ),
                  TextField(
                    controller: nameTec,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.title),
                      labelText: '제목',
                    ),
                  ),
                  TextField(
                    controller: bodyTec,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.text_snippet_outlined),
                      labelText: '내용',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    // 첫번째 요일 시간 선택 row
                    visible: isPeriodic,
                    child: Row(
                      children: [
                        DropdownMenu(
                          dropdownMenuEntries: days,
                          label: const Text('요일'),
                          controller: daysTec1,
                          onSelected: (value) {
                            print(value);
                          },
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.center,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: TimePickerSpinner(
                                    is24HourMode: true,
                                    minutesInterval: 30,
                                    isForce2Digits: true,
                                    isShowSeconds: false,
                                    onTimeChange: (time) {
                                      var pickedTime =
                                          DateFormat('HH:mm').format(time);
                                      timeTec1.text = pickedTime;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                              // TimeOfDay? pickedTime =
                              //     await showIntervalTimePicker(
                              //         context: context,
                              //         initialTime: TimeOfDay.now(),
                              //         interval: 30,
                              //         visibleStep: VisibleStep.thirtieths);
                              // if (pickedTime != null) {
                              //   setState(() {
                              //     var df = DateFormat("a h:mm", "ko");
                              //     var dt = df.parse(pickedTime.format(context));
                              //     var finaltime =
                              //         DateFormat("HH:mm").format(dt);
                              //     timeTec1.text = finaltime;
                              //   });
                              // }
                            },
                            controller: timeTec1,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.center,
                            onTap: () async {
                              TimeOfDay? pickedTime =
                                  await showIntervalTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      interval: 30,
                                      visibleStep: VisibleStep.thirtieths);
                              if (pickedTime != null) {
                                setState(() {
                                  var df = DateFormat("a h:mm", "ko");
                                  var dt = df.parse(pickedTime.format(context));
                                  var finaltime =
                                      DateFormat("HH:mm").format(dt);
                                  timeTec2.text = finaltime;
                                });
                              }
                            },
                            controller: timeTec2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAdded)
                    Visibility(
                      // 두번째 요일 시간 선택 row
                      visible: isPeriodic,
                      child: Row(
                        children: [
                          DropdownMenu(
                            dropdownMenuEntries: days,
                            label: const Text('요일'),
                            controller: daysTec2,
                            onSelected: (value) {
                              print(value);
                            },
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.center,
                              onTap: () async {
                                TimeOfDay? pickedTime =
                                    await showIntervalTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        interval: 30,
                                        visibleStep: VisibleStep.thirtieths);
                                if (pickedTime != null) {
                                  setState(() {
                                    var df = DateFormat("a h:mm", "ko");
                                    var dt =
                                        df.parse(pickedTime.format(context));
                                    var finaltime =
                                        DateFormat("HH:mm").format(dt);
                                    timeTec3.text = finaltime;
                                  });
                                }
                              },
                              controller: timeTec3,
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.center,
                              onTap: () async {
                                TimeOfDay? pickedTime =
                                    await showIntervalTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  interval: 30,
                                  visibleStep: VisibleStep.thirtieths,
                                );
                                if (pickedTime != null) {
                                  setState(() {
                                    var df = DateFormat("a h:mm", "ko");
                                    var dt =
                                        df.parse(pickedTime.format(context));
                                    var finaltime =
                                        DateFormat("HH:mm").format(dt);
                                    timeTec4.text = finaltime;
                                  });
                                }
                              },
                              controller: timeTec4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Visibility(
                    visible: isPeriodic,
                    child: TextButton(
                        style: const ButtonStyle(
                            foregroundColor:
                                MaterialStatePropertyAll(Colors.lightBlue)),
                        onPressed: () {
                          isAdded = !isAdded;
                          setState(() {});
                        },
                        child: isAdded
                            ? const Text('날짜 및 시간 제거')
                            : const Text('날짜 및 시간 추가')),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    visible: !isPeriodic,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          child: TimePickerSpinner(
                            is24HourMode: true,
                            minutesInterval: 30,
                            isForce2Digits: true,
                            isShowSeconds: false,
                            onTimeChange: (time) {
                              if (dateTec != '') {
                                var pickedTime =
                                    DateFormat('HH:mm:ss').format(time);
                                startTime = ('${dateTec.text}T$pickedTime')
                                    .split(' ')[0];
                              }
                            },
                          ),
                        ),
                        Container(
                          child: TimePickerSpinner(
                            is24HourMode: true,
                            minutesInterval: 30,
                            isForce2Digits: true,
                            isShowSeconds: false,
                            onTimeChange: (time) {
                              if (dateTec != '') {
                                var pickedTime =
                                    DateFormat('HH:mm:ss').format(time);
                                endTime = ('${dateTec.text}T$pickedTime')
                                    .split(' ')[0];
                              }
                              print('Start : $startTime');
                              print('End : $endTime');
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  OutlinedButton(
                      onPressed: () async {
                        var periodicTimeStringList = [
                          if ((daysTec1.text != '') &&
                              (timeTec1.text != '') &&
                              (timeTec2.text != ''))
                            "${daysTec1.text},${timeTec1.text}-${timeTec2.text}",
                          if (((daysTec2.text != '') &&
                              (timeTec3.text != '') &&
                              (timeTec4.text != '')))
                            "${daysTec2.text},${timeTec3.text}-${timeTec4.text}",
                        ];
                        print('pSL : $periodicTimeStringList');
                        var postBody = isPeriodic
                            ? {
                                'name':
                                    (nameTec.text == '') ? '제목' : nameTec.text,
                                'body':
                                    (bodyTec.text == '') ? '내용' : bodyTec.text,
                                'periodicType': isPeriodic,
                                'periodicTimeStringList':
                                    periodicTimeStringList,
                              }
                            : {
                                'name':
                                    (nameTec.text == '') ? '제목' : nameTec.text,
                                'body':
                                    (bodyTec.text == '') ? '내용' : bodyTec.text,
                                'periodicType': isPeriodic,
                                'startTime': startTime,
                                'endTime': endTime,
                              };
                        var url = Uri.http(
                            baseUri, '/timetable/team/saveSchedule', {
                          'groupId': '${widget.groupData!['groupId']}',
                          'isPublicTypeSchedule': 'true'
                        });
                        print(url);
                        var response = await http.post(url,
                            headers: <String, String>{
                              'Content-Type': 'application/json',
                              'authorization': 'Bearer $jwtToken'
                            },
                            body: jsonEncode(postBody));
                        if (response.statusCode == 200) {
                          print('success!');
                          print(response.body);
                          Fluttertoast.showToast(msg: '추가되었습니다');
                        } else {
                          print('fail..');
                          print(response.body);
                          Fluttertoast.showToast(msg: '등록 실패, 입력을 확인하세요');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          // shape: const StadiumBorder(),
                          side: const BorderSide(color: Colors.grey)),
                      child: const Text(
                        '추가하기',
                        style: TextStyle(color: Colors.black),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
