import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class LectureSearchResultScreen extends ConsumerStatefulWidget {
  const LectureSearchResultScreen({super.key});

  @override
  ConsumerState<LectureSearchResultScreen> createState() => _LectureSearchResultScreenState();
}

class _LectureSearchResultScreenState extends ConsumerState<LectureSearchResultScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<List<Lecture>> initialLectureList;
  late Future<List<Lecture>> lectureList;
  List<bool>? isTapList;
  bool isSearch = false;
  Future<List<dynamic>>? allSubjectKindFuture;
  String? initSubjectKind;
  String? classInfo = "전체";
  String? discriminateInfo = "전체";
  String? deptInfo = "전체";
  List<String> classKindList = [];
  List<bool> isClassTabList = [];
  Future<List<Lecture>> getLectureList(String? word) async {
    var url = Uri.http(
      baseUri,
      '/subject/search',
    );
    var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'}, body: jsonEncode({'name': word}));
    dynamic data;
    if (response.statusCode == 200) {
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      data = parsedJson.map((e) => Lecture.fromJson(e)).toList();
    } else {
      print(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: '검색 에러');
    }
    return data;
  }

  saveToSchedule(var id) async {
    var url = Uri.http(baseUri, '/subject/saveSubjectToMember', {'subjectId': '$id'});
    var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '추가되었습니다');
    } else {
      print(utf8.decode(response.bodyBytes));
    }
  }

  @override
  void initState() {
    super.initState();
    initialLectureList = getLectureList("");
    var listLength = 0; // then에서 처리하는 변수라 저장할때 안쓰는 변수라고 사라지길래 0으로 초기화했음
    initialLectureList.then((value) => listLength = value.length).then((value) => isTapList = List.filled(listLength, false));
    lectureList = initialLectureList;
    classInfo = "전체";
    classKindList.add("1학년");
    classKindList.add("2학년");
    classKindList.add("3학년");
    classKindList.add("4학년");
    classKindList.add("기타");
    isClassTabList = List.filled(classKindList.length, true);
  }

  lectureComponent({required Lecture lecture, required int num}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isTapList![num] = !isTapList![num];
        });
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromARGB(255, 255, 255, 255), boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                            width: 30,
                            height: 30,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              // child: Image.asset(job.companyLogo),
                              child: const Icon(FontAwesomeIcons.book),
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            child: Column(
                          children: [
                            Text('${lecture.subjectname}', style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${lecture.prof_nm}',
                              style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${lecture.class_nm}',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                        child: Text(
                          '${lecture.shyr}학년',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                        child: Text(
                          '${lecture.subject_div}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                        child: Text(
                          '${lecture.dept}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Visibility(
                  visible: isTapList![num],
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          saveToSchedule(lecture.id);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 82, 195, 248)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ))),
                        child: const Text(
                          "강의 추가",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ))
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 244, 248),
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                  padding: const EdgeInsets.only(left: 20),
                  onPressed: () {
                    setState(() {
                      isSearch = !isSearch;
                    });
                  },
                  icon: const Icon(
                    Icons.filter_list,
                    color: Color.fromARGB(255, 25, 141, 230),
                  )),
              Container(
                height: 45,
                width: 300,
                margin: const EdgeInsets.only(left: 20),
                child: TextField(
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                    hintText: "과목 이름을 입력해주세요",
                    hintStyle: const TextStyle(fontSize: 14),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      lectureList = getLectureList(value);
                    });
                  },
                ),
              ),
            ],
          ),
          Visibility(
            visible: isSearch,
            child: (Row(children: [
              const SizedBox(
                width: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.question,
                      body: Center(
                          child: Container(
                        height: 300,
                        width: 250,
                        alignment: Alignment.center,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: classKindList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print("clicked. gesture");
                                    isClassTabList[index] = !isClassTabList[index];
                                  });
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                        value: isClassTabList[index],
                                        onChanged: (value) {
                                          setState(() {
                                            isClassTabList[index] = value!;
                                          });
                                        }),
                                    Text(classKindList[index])
                                  ],
                                ),
                              );
                            }),
                      )),
                      btnOkOnPress: () async {
                        print("ok..");
                      },
                      btnCancelOnPress: () {},
                    ).show();
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ))),
                  child: Text("학년:$classInfo")),
              const SizedBox(
                width: 20,
              ),
              OutlinedButton(
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.question,
                    body: Center(
                        child: Container(
                      height: 300,
                      width: 250,
                      alignment: Alignment.center,
                      child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: classKindList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  print("clicked. gesture");
                                  isClassTabList[index] = !isClassTabList[index];
                                });
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: isClassTabList[index],
                                      onChanged: (value) {
                                        setState(() {
                                          isClassTabList[index] = value!;
                                        });
                                      }),
                                  Text(classKindList[index])
                                ],
                              ),
                            );
                          }),
                    )),
                    btnOkOnPress: () async {
                      print("ok..");
                    },
                    btnCancelOnPress: () {},
                  ).show();
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ))),
                child: Text("구분:$discriminateInfo"),
              ),
              const SizedBox(
                width: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.question,
                      body: Center(
                          child: Container(
                        height: 300,
                        width: 250,
                        alignment: Alignment.center,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: classKindList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print("clicked. gesture");
                                    isClassTabList[index] = !isClassTabList[index];
                                  });
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                        value: isClassTabList[index],
                                        onChanged: (value) {
                                          setState(() {
                                            isClassTabList[index] = value!;
                                          });
                                        }),
                                    Text(classKindList[index])
                                  ],
                                ),
                              );
                            }),
                      )),
                      btnOkOnPress: () async {
                        print("ok..");
                      },
                      btnCancelOnPress: () {},
                    ).show();
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ))),
                  child: Text("학과:$deptInfo")),
            ])),
          ),
          Expanded(
              child: FutureBuilder(
            future: lectureList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return lectureComponent(lecture: snapshot.data![index], num: index);
                    });
              } else {
                print("No data..!!");
                return const Center(child: Text('불러오는 중...'));
              }
            },
          ))
        ],
      ),
    );
  }
}
