import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:emptysaver_fe/widgets/network_image.dart';
import 'package:emptysaver_fe/core//assets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:time_range_picker/time_range_picker.dart';

class UpdateScheduleScreen extends ConsumerStatefulWidget {
  int? scheduleId;
  int? groupId;

  UpdateScheduleScreen({
    super.key,
    this.scheduleId,
    this.groupId,
  });

  @override
  ConsumerState<UpdateScheduleScreen> createState() => _UpdateScheduleScreenState();
}

class _UpdateScheduleScreenState extends ConsumerState<UpdateScheduleScreen> {
  List<DateTime>? timeList;
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  final List<bool> _selections = List.generate(2, (_) => false);
  bool isPeriodic = false;
  bool isChecked = false;
  // var dateTec = TextEditingController(text: '날짜를 선택해주세요');
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
  String dateInfo = "일정을 선택해주세요";
  List<DropdownMenuEntry<String>> days = [
    const DropdownMenuEntry(value: '월', label: '월'),
    const DropdownMenuEntry(value: '화', label: '화'),
    const DropdownMenuEntry(value: '수', label: '수'),
    const DropdownMenuEntry(value: '목', label: '목'),
    const DropdownMenuEntry(value: '금', label: '금'),
    const DropdownMenuEntry(value: '토', label: '토'),
    const DropdownMenuEntry(value: '일', label: '일'),
  ];
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

  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30.0,
          ),
          const CircleAvatar(
            maxRadius: 50,
            backgroundColor: Colors.transparent,
            child: PNetworkImage(origami),
          ),
          const SizedBox(
            height: 20.0,
          ),
          _buildAddScheduleForm(context),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[
          //     FloatingActionButton(
          //       mini: true,
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       backgroundColor: Colors.blue,
          //       child: const Icon(Icons.arrow_back),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  Container _buildAddScheduleForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
              height: 600,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 90.0,
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
                        keyboardType: TextInputType.visiblePassword,
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
                              Icons.school,
                              color: Colors.blue,
                            )),
                        keyboardType: TextInputType.visiblePassword,
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
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            DateTime currentTime = await NTP.now();
                            currentTime = currentTime.toUtc().add(const Duration(hours: 9));
                            timeList = await showOmniDateTimeRangePicker(
                              context: context,
                              startInitialDate: currentTime,
                              endInitialDate: currentTime,
                              minutesInterval: 30,
                            );
                            String? start = timeList?.elementAt(0).toString();
                            if (start != null) {
                              List<String> split = start.split(" ");
                              startTime = '${split[0]}T${split[1]}';
                              print("startTIme: $startTime");
                            }
                            print("start time : $start");
                            String? end = timeList?.elementAt(1).toString();
                            if (end != null) {
                              List<String> split = end.split(" ");
                              endTime = '${split[0]}T${split[1]}';
                              print("endTime: $endTime");
                            }
                            print("end time : $end");
                            setState(() {
                              dateInfo = (start == null || end == null ? "일정을 선택해주세요" : '${start.split(".")[0]} ~ ${end.split(".")[0]}');
                            });
                          },
                        ),
                        Text(dateInfo)
                      ],
                    ),
                  ),
                  Visibility(
                      visible: isPeriodic,
                      child: Row(
                        children: [
                          DropdownButtonHideUnderline(
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
                                });
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
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
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              width: 100,
                              child: TextField(
                                controller: nameTec,
                                style: const TextStyle(color: Colors.blue),
                                decoration: InputDecoration(
                                    hintText: "이름",
                                    hintStyle: TextStyle(color: Colors.blue.shade200),
                                    border: InputBorder.none,
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    )),
                                keyboardType: TextInputType.visiblePassword,
                              )),
                          TextButton(
                            onPressed: () async {
                              TimeRange result = await showTimeRangePicker(context: context, interval: const Duration(minutes: 30));
                              print("result $result");
                            },
                            child: const Text("시간 선택"),
                          ),
                        ],
                      )),
                  if (isAdded)
                    Visibility(
                      // 두번째 요일 시간 선택 row
                      visible: isPeriodic,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Icon(
                                Icons.list,
                                size: 16,
                                color: Colors.yellow,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  'Select Item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
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
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: 160,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                              color: Colors.redAccent,
                            ),
                            elevation: 2,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: Colors.yellow,
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              width: 200,
                              padding: null,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.redAccent,
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
                  Visibility(
                    visible: isPeriodic,
                    child: TextButton(
                        style: const ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.lightBlue)),
                        onPressed: () {
                          isAdded = !isAdded;
                          setState(() {});
                        },
                        child: isAdded ? const Text('날짜 및 시간 제거') : const Text('날짜 및 시간 추가')),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                    child: Divider(
                      color: Colors.blue.shade400,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.blue.shade600,
                child: const Icon(Icons.person),
              ),
            ],
          ),
          SizedBox(
            height: 600,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0)),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  if (!isChecked) {
                    Fluttertoast.showToast(msg: '일정 타입을 선택해주세요');
                    return;
                  }

                  var periodicTimeStringList = [
                    if ((daysTec1.text != '') && (timeTec1.text != '') && (timeTec2.text != '')) "${daysTec1.text},${timeTec1.text}-${timeTec2.text}",
                    if (((daysTec2.text != '') && (timeTec3.text != '') && (timeTec4.text != ''))) "${daysTec2.text},${timeTec3.text}-${timeTec4.text}",
                  ];
                  print('pSL : $periodicTimeStringList');
                  var postBody = isPeriodic
                      ? {
                          'name': (nameTec.text == '') ? '제목' : nameTec.text,
                          'body': (bodyTec.text == '') ? '내용' : bodyTec.text,
                          'periodicType': isPeriodic,
                          'periodicTimeStringList': periodicTimeStringList,
                        }
                      : {
                          'name': (nameTec.text == '') ? '제목' : nameTec.text,
                          'body': (bodyTec.text == '') ? '내용' : bodyTec.text,
                          'periodicType': isPeriodic,
                          'startTime': startTime,
                          'endTime': endTime,
                        };
                  var url = Uri.http(baseUri, '/timetable/updateSchedule', {'scheduleId': '${widget.scheduleId}'});
                  var response = await http.put(url, headers: <String, String>{'Content-Type': 'application/json', 'authorization': 'Bearer $jwtToken'}, body: jsonEncode(postBody));
                  if (response.statusCode == 200) {
                    print('success!');
                    Fluttertoast.showToast(msg: '변경되었습니다');
                    Navigator.popAndPushNamed(context, '/bar');
                  } else {
                    print(utf8.decode(response.bodyBytes));
                    Fluttertoast.showToast(msg: '변경 실패, 입력을 확인하세요');
                  }
                },
                child: const Text("변경하기", style: TextStyle(color: Colors.white70)),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일정 추가')),
      body: _buildPageContent(context),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: DropdownButtonHideUnderline(
  //         child: DropdownButton2(
  //           isExpanded: true,
  //           hint: Row(
  //             children: const [
  //               Icon(
  //                 Icons.list,
  //                 size: 16,
  //                 color: Colors.yellow,
  //               ),
  //               SizedBox(
  //                 width: 4,
  //               ),
  //               Expanded(
  //                 child: Text(
  //                   'Select Item',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.yellow,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           items: items
  //               .map((item) => DropdownMenuItem<String>(
  //                     value: item,
  //                     child: Text(
  //                       item,
  //                       style: const TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                       ),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ))
  //               .toList(),
  //           value: selectedValue,
  //           onChanged: (value) {
  //             setState(() {
  //               selectedValue = value as String;
  //             });
  //           },
  //           buttonStyleData: ButtonStyleData(
  //             height: 50,
  //             width: 160,
  //             padding: const EdgeInsets.only(left: 14, right: 14),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(14),
  //               border: Border.all(
  //                 color: Colors.black26,
  //               ),
  //               color: Colors.redAccent,
  //             ),
  //             elevation: 2,
  //           ),
  //           iconStyleData: const IconStyleData(
  //             icon: Icon(
  //               Icons.arrow_forward_ios_outlined,
  //             ),
  //             iconSize: 14,
  //             iconEnabledColor: Colors.yellow,
  //             iconDisabledColor: Colors.grey,
  //           ),
  //           dropdownStyleData: DropdownStyleData(
  //               maxHeight: 200,
  //               width: 200,
  //               padding: null,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(14),
  //                 color: Colors.redAccent,
  //               ),
  //               elevation: 8,
  //               offset: const Offset(-20, 0),
  //               scrollbarTheme: ScrollbarThemeData(
  //                 radius: const Radius.circular(40),
  //                 thickness: MaterialStateProperty.all(6),
  //                 thumbVisibility: MaterialStateProperty.all(true),
  //               )),
  //           menuItemStyleData: const MenuItemStyleData(
  //             height: 40,
  //             padding: EdgeInsets.only(left: 14, right: 14),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   var jwtToken = ref.read(tokensProvider.notifier).state[0];
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('일정 추가'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(10),
  //       child: Center(
  //         child: GestureDetector(
  //           onTap: () => FocusScope.of(context).unfocus(),
  //           child: SingleChildScrollView(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const SizedBox(
  //                   height: 50,
  //                 ),
  //                 TextField(
  //                   controller: nameTec,
  //                   decoration: const InputDecoration(
  //                     icon: Icon(Icons.title),
  //                     labelText: '제목',
  //                   ),
  //                 ),
  //                 TextField(
  //                   controller: bodyTec,
  //                   decoration: const InputDecoration(
  //                     icon: Icon(Icons.text_snippet_outlined),
  //                     labelText: '내용',
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 50,
  //                 ),
  //                 ToggleButtons(
  //                   isSelected: _selections,
  //                   children: const [
  //                     Padding(
  //                       padding: EdgeInsets.all(15),
  //                       child: Text("이번에만 할래요"),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(15),
  //                       child: Text("매주 할래요"),
  //                     )
  //                   ],
  //                   onPressed: (index) async {
  //                     isChecked = true;
  //                     for (int i = 0; i < _selections.length; i++) {
  //                       _selections[i] = (i == index);
  //                     }
  //                     if (index == 0) {
  //                       isPeriodic = false;
  //                       print(isPeriodic);
  //                     } else {
  //                       isPeriodic = true;
  //                       print(isPeriodic);
  //                     }
  //                     setState(() {});
  //                   },
  //                 ),
  //                 Visibility(
  //                   visible: isChecked && !isPeriodic,
  //                   child: Row(
  //                     children: [
  //                       IconButton(
  //                         icon: Icon(Icons.calendar_month),
  //                         onPressed: () async {
  //                           DateTime currentTime = await NTP.now();
  //                           currentTime =
  //                               currentTime.toUtc().add(Duration(hours: 9));
  //                           timeList = await showOmniDateTimeRangePicker(
  //                             context: context,
  //                             startInitialDate: currentTime,
  //                             endInitialDate: currentTime,
  //                             minutesInterval: 30,
  //                           );
  //                           String? start = timeList?.elementAt(0).toString();
  //                           if (start != null) {
  //                             List<String> split = start.split(" ");
  //                             startTime = '${split[0]}T${split[1]}';
  //                             print("startTIme: ${startTime}");
  //                           }
  //                           print("start time : ${start}");
  //                           String? end = timeList?.elementAt(1).toString();
  //                           if (end != null) {
  //                             List<String> split = end.split(" ");
  //                             endTime = '${split[0]}T${split[1]}';
  //                             print("endTime: ${endTime}");
  //                           }
  //                           print("end time : ${end}");
  //                           setState(() {
  //                             dateInfo = (start == null || end == null
  //                                 ? "일정을 선택해주세요"
  //                                 : '${start.split(".")[0]} ~ ${end.split(".")[0]}');
  //                           });
  //                         },
  //                       ),
  //                       Text('${dateInfo}')
  //                     ],
  //                     // controller: dateTec,
  //                     // decoration: const InputDecoration(
  //                     //   icon: Icon(Icons.calendar_month_outlined),
  //                     //   labelText: '날짜 선택',
  //                     // ),
  //                   ),
  //                 ),
  //                 const SizedBox(
  //                   height: 30,
  //                 ),
  //                 Visibility(
  //                   // 첫번째 요일 시간 선택 row
  //                   visible: isPeriodic,
  //                   child: Row(
  //                     children: [
  //                       DropdownMenu(
  //                         dropdownMenuEntries: days,
  //                         label: const Text('요일'),
  //                         controller: daysTec1,
  //                         onSelected: (value) {
  //                           print(value);
  //                         },
  //                       ),
  //                       Expanded(
  //                         child: TextField(
  //                           textAlign: TextAlign.center,
  //                           onTap: () async {
  //                             TimeOfDay? pickedTime =
  //                                 await showIntervalTimePicker(
  //                                     context: context,
  //                                     initialTime: TimeOfDay.now(),
  //                                     interval: 30,
  //                                     visibleStep: VisibleStep.thirtieths);
  //                             if (pickedTime != null) {
  //                               setState(() {
  //                                 var df = DateFormat("a h:mm", "ko");
  //                                 var dt = df.parse(pickedTime.format(context));
  //                                 var finaltime =
  //                                     DateFormat("HH:mm").format(dt);
  //                                 timeTec1.text = finaltime;
  //                               });
  //                             }
  //                             // showDialog(
  //                             //   context: context,
  //                             //   builder: (context) => AlertDialog(
  //                             //     content: TimePickerSpinner(
  //                             //       is24HourMode: true,
  //                             //       minutesInterval: 30,
  //                             //       isForce2Digits: true,
  //                             //       isShowSeconds: false,
  //                             //       onTimeChange: (time) {
  //                             //         var pickedTime =
  //                             //             DateFormat('HH:mm').format(time);
  //                             //         timeTec1.text = pickedTime;
  //                             //         setState(() {});
  //                             //       },
  //                             //     ),
  //                             //   ),
  //                             // );
  //                           },
  //                           controller: timeTec1,
  //                         ),
  //                       ),
  //                       const SizedBox(
  //                         width: 30,
  //                       ),
  //                       Expanded(
  //                         child: TextField(
  //                           textAlign: TextAlign.center,
  //                           onTap: () async {
  //                             TimeOfDay? pickedTime =
  //                                 await showIntervalTimePicker(
  //                                     context: context,
  //                                     initialTime: TimeOfDay.now(),
  //                                     interval: 30,
  //                                     visibleStep: VisibleStep.thirtieths);
  //                             if (pickedTime != null) {
  //                               setState(() {
  //                                 var df = DateFormat("a h:mm", "ko");
  //                                 var dt = df.parse(pickedTime.format(context));
  //                                 var finaltime =
  //                                     DateFormat("HH:mm").format(dt);
  //                                 timeTec2.text = finaltime;
  //                               });
  //                             }
  //                           },
  //                           controller: timeTec2,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (isAdded)
  //                   Visibility(
  //                     // 두번째 요일 시간 선택 row
  //                     visible: isPeriodic,
  //                     child: Row(
  //                       children: [
  //                         DropdownMenu(
  //                           dropdownMenuEntries: days,
  //                           label: const Text('요일'),
  //                           controller: daysTec2,
  //                           onSelected: (value) {
  //                             print(value);
  //                           },
  //                         ),
  //                         Expanded(
  //                           child: TextField(
  //                             textAlign: TextAlign.center,
  //                             onTap: () async {
  //                               TimeOfDay? pickedTime =
  //                                   await showIntervalTimePicker(
  //                                       context: context,
  //                                       initialTime: TimeOfDay.now(),
  //                                       interval: 30,
  //                                       visibleStep: VisibleStep.thirtieths);
  //                               if (pickedTime != null) {
  //                                 setState(() {
  //                                   var df = DateFormat("a h:mm", "ko");
  //                                   var dt =
  //                                       df.parse(pickedTime.format(context));
  //                                   var finaltime =
  //                                       DateFormat("HH:mm").format(dt);
  //                                   timeTec3.text = finaltime;
  //                                 });
  //                               }
  //                             },
  //                             controller: timeTec3,
  //                           ),
  //                         ),
  //                         const SizedBox(
  //                           width: 30,
  //                         ),
  //                         Expanded(
  //                           child: TextField(
  //                             textAlign: TextAlign.center,
  //                             onTap: () async {
  //                               TimeOfDay? pickedTime =
  //                                   await showIntervalTimePicker(
  //                                 context: context,
  //                                 initialTime: TimeOfDay.now(),
  //                                 interval: 30,
  //                                 visibleStep: VisibleStep.thirtieths,
  //                               );
  //                               if (pickedTime != null) {
  //                                 setState(() {
  //                                   var df = DateFormat("a h:mm", "ko");
  //                                   var dt =
  //                                       df.parse(pickedTime.format(context));
  //                                   var finaltime =
  //                                       DateFormat("HH:mm").format(dt);
  //                                   timeTec4.text = finaltime;
  //                                 });
  //                               }
  //                             },
  //                             controller: timeTec4,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 Visibility(
  //                   visible: isPeriodic,
  //                   child: TextButton(
  //                       style: const ButtonStyle(
  //                           foregroundColor:
  //                               MaterialStatePropertyAll(Colors.lightBlue)),
  //                       onPressed: () {
  //                         isAdded = !isAdded;
  //                         setState(() {});
  //                       },
  //                       child: isAdded
  //                           ? const Text('날짜 및 시간 제거')
  //                           : const Text('날짜 및 시간 추가')),
  //                 ),
  //                 const SizedBox(
  //                   height: 30,
  //                 ),
  //                 const SizedBox(
  //                   height: 30,
  //                 ),
  //                 OutlinedButton(
  //                     onPressed: () async {
  //                       if (!isChecked) {
  //                         Fluttertoast.showToast(msg: '일정 타입을 선택해주세요');
  //                         return;
  //                       }

  //                       var periodicTimeStringList = [
  //                         if ((daysTec1.text != '') &&
  //                             (timeTec1.text != '') &&
  //                             (timeTec2.text != ''))
  //                           "${daysTec1.text},${timeTec1.text}-${timeTec2.text}",
  //                         if (((daysTec2.text != '') &&
  //                             (timeTec3.text != '') &&
  //                             (timeTec4.text != '')))
  //                           "${daysTec2.text},${timeTec3.text}-${timeTec4.text}",
  //                       ];
  //                       print('pSL : $periodicTimeStringList');
  //                       var postBody = isPeriodic
  //                           ? {
  //                               'name':
  //                                   (nameTec.text == '') ? '제목' : nameTec.text,
  //                               'body':
  //                                   (bodyTec.text == '') ? '내용' : bodyTec.text,
  //                               'periodicType': isPeriodic,
  //                               'periodicTimeStringList':
  //                                   periodicTimeStringList,
  //                             }
  //                           : {
  //                               'name':
  //                                   (nameTec.text == '') ? '제목' : nameTec.text,
  //                               'body':
  //                                   (bodyTec.text == '') ? '내용' : bodyTec.text,
  //                               'periodicType': isPeriodic,
  //                               'startTime': startTime,
  //                               'endTime': endTime,
  //                             };
  //                       var url = Uri.http(baseUri, '/timetable/saveSchedule');
  //                       print(url);
  //                       var response = await http.post(url,
  //                           headers: <String, String>{
  //                             'Content-Type': 'application/json',
  //                             'authorization': 'Bearer $jwtToken'
  //                           },
  //                           body: jsonEncode(postBody));
  //                       if (response.statusCode == 200) {
  //                         print('success!');
  //                         print(response.body);
  //                         Fluttertoast.showToast(msg: '추가되었습니다');
  //                         Navigator.popAndPushNamed(context, '/bar');
  //                       } else {
  //                         print('fail..');
  //                         print(response.body);
  //                         Fluttertoast.showToast(msg: '등록 실패, 입력을 확인하세요');
  //                       }
  //                     },
  //                     style: OutlinedButton.styleFrom(
  //                         // shape: const StadiumBorder(),
  //                         side: const BorderSide(color: Colors.grey)),
  //                     child: const Text(
  //                       '추가하기',
  //                       style: TextStyle(color: Colors.black),
  //                     )),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
