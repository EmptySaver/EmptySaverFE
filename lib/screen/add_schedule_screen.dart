import 'dart:convert';

import 'package:day_picker/day_picker.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddScheduleScreen extends ConsumerStatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  ConsumerState<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends ConsumerState<AddScheduleScreen> {
  var baseUri = '43.201.208.100:8080';
  final List<bool> _selections = List.generate(2, (_) => false);
  final _days = [
    DayInWeek('월'),
    DayInWeek('화'),
    DayInWeek('수'),
    DayInWeek('목'),
    DayInWeek('금'),
    DayInWeek('토'),
    DayInWeek('일'),
  ];
  bool isPeriodic = false;
  var dateTec = TextEditingController(text: '');
  String? startTime;
  String? endTime;

  @override
  Widget build(BuildContext context) {
    var jwtToken = ref.read(tokensProvider.notifier).state[0];
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  Visibility(
                    visible: isPeriodic,
                    child: SelectWeekDays(
                      onSelect: (val) {
                        print(val);
                      },
                      days: _days,
                      backgroundColor: Colors.black,
                    ),
                  ),
                  TextField(
                    controller: dateTec,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_month_outlined),
                      labelText: '날짜 선택',
                    ),
                    onTap: () async {
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
                    },
                  ),
                  TimePickerSpinner(
                    is24HourMode: true,
                    minutesInterval: 30,
                    isForce2Digits: true,
                    isShowSeconds: false,
                    onTimeChange: (time) {
                      if (dateTec != '') {
                        var pickedTime = DateFormat('HH:mm:ss').format(time);
                        startTime =
                            ('${dateTec.text}T$pickedTime').split(' ')[0];
                      }
                    },
                  ),
                  TimePickerSpinner(
                    is24HourMode: true,
                    minutesInterval: 30,
                    isForce2Digits: true,
                    isShowSeconds: false,
                    onTimeChange: (time) {
                      if (dateTec != '') {
                        var pickedTime = DateFormat('HH:mm:ss').format(time);
                        endTime = ('${dateTec.text}T$pickedTime').split(' ')[0];
                      }
                      print('Start : $startTime');
                      print('End : $endTime');
                    },
                  ),
                  OutlinedButton(
                      onPressed: () async {
                        var postBody = {
                          'name': 'test',
                          'body': '내용',
                          'periodicType': 'false',
                          'periodicTimeStringList': [],
                          'startTime': startTime,
                          'endTime': endTime,
                        };
                        var url = Uri.http(baseUri, '/timetable/saveSchedule');
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
                        } else {
                          print('fail..');
                          print(response.body);
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
