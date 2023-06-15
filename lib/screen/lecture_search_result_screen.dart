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
  List<Lecture> initialLectureList = [];
  List<Lecture> lectureList = [];
  List<bool>? isTapList;
  bool isFilter = false;
  Future<List<dynamic>>? allSubjectKindFuture;
  String? initSubjectKind;
  String? classInfo = "전체";
  String? discriminateInfo = "전체";
  String? deptInfo = "전체";
  List<String> classKindList = [];
  List<bool> isClassTabList = [];
  List<String> discriminateList = [];
  List<bool> isDiscTablList = [];
  List<Dept> deptList = [];
  bool isUpper = true;
  int deptSubIndex = -1;
  var searchTec = TextEditingController(text: '');
  getLectureList(String? word) async {
    var url = Uri.http(
      baseUri,
      '/subject/search',
    );
    var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'}, body: jsonEncode({'name': word}));
    dynamic data;
    if (response.statusCode == 200) {
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      data = parsedJson.map((e) => Lecture.fromJson(e)).toList();
      // lectureList.addAll(data);
      print("get Lecture ;${data[0].toString()}");
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: '검색 에러');
    }
  }

  getDivNameList() async {
    var url = Uri.http(
      baseUri,
      '/subject/getAllDivInfoList',
    );
    var response = await http.get(
      url,
      headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json'},
    );
    dynamic data;
    if (response.statusCode == 200) {
      print("got data from div name list : ${utf8.decode(response.bodyBytes)}");
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      data = parsedJson.map((e) => Dept.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: '정보를 불러오지 못했습니다.');
    }
  }

  saveToSchedule(var id) async {
    var url = Uri.http(baseUri, '/timetable/saveScheduleByCopy', {
      'scheduleId': '$id',
      'hideType': 'false',
    });
    var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: '추가되었습니다');
    } else {
      print(utf8.decode(response.bodyBytes));
    }
  }

  @override
  void initState() {
    // initialLectureList =
    getLectureList("").then((value) => setState(() {
          lectureList = value;
          initialLectureList = value;
          isTapList = List.filled(value.length, false);
        }));
    // var listLength;
    // initialLectureList
    //     .then((value) => listLength = value.length)
    //     .then((value) => isTapList = List.filled(listLength, false));
    classInfo = "전체";
    classKindList.add("1");
    classKindList.add("2");
    classKindList.add("3");
    classKindList.add("4");
    classKindList.add("기타");
    isClassTabList = List.filled(classKindList.length, true);
    discriminateList.add("교양선택");
    discriminateList.add("교양필수");
    discriminateList.add("ROTC");
    discriminateList.add("교직");
    discriminateList.add("전공선택");
    discriminateList.add("전공필수");
    discriminateList.add("선수");
    isDiscTablList = List.filled(discriminateList.length, true);

    //의사소통 교실 -> 상위 부서가 없음 == 그냥 이걸 상위 부서라고 합시더..
    getDivNameList().then((value) => setState(() {
          deptList.add(Dept(upperName: "전체", deptNameList: List.empty()));
          print("before Value :$value");
          value[0] = Dept(upperName: "의사소통교실", deptNameList: ["의사소통교실"]);
          deptList.addAll(value);
          print("now Value :$value");
        }));

    super.initState();
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.selected,
      MaterialState.focused,
      MaterialState.pressed,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.white;
    }
    return Colors.pink;
  }

  divider() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
      child: Divider(
        color: Colors.blue.shade400,
      ),
    );
  }

  lectureComponent({required Lecture lecture, required int num}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isTapList![num] = !isTapList![num];
            });
          },
          behavior: HitTestBehavior.translucent,
          child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${lecture.subjectname}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${lecture.prof_nm}',
                      style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${lecture.class_nm}',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.grey.shade200),
                          child: Text(
                            '${lecture.shyr}학년',
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.grey.shade200),
                          child: Text(
                            '${lecture.subject_div}',
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.grey.shade200),
                          child: Text(
                            '${lecture.dept}',
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Visibility(
                    visible: isTapList![num],
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              saveToSchedule(lecture.id);
                            },
                            child: const Text(
                              "강의 추가",
                            ),
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const Divider(
          thickness: 1.0,
        )
      ],
    );
  }

  showGradeDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              title: const Text("검색하고 싶은 학년을 모두 선택해주세요"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: 330,
                  width: 270,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: classKindList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  print("clicked. gesture");
                                  isClassTabList[index] = !isClassTabList[index];
                                });
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: isClassTabList[index],
                                      checkColor: Colors.redAccent,
                                      activeColor: Colors.white,
                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          isClassTabList[index] = value!;
                                        });
                                      }),
                                  Text(classKindList[index] == "기타" ? "기타" : "${classKindList[index]}학년")
                                ],
                              ),
                            ),
                            divider()
                          ],
                        );
                      }),
                ),
              ]),
              actions: <Widget>[
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              isClassTabList = List.filled(isClassTabList.length, true);
                            },
                          );
                        },
                        child: const Text("전체 선택")),
                    TextButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              isClassTabList = List.filled(isClassTabList.length, false);
                            },
                          );
                        },
                        child: const Text("전체 해제")),
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            List<Lecture> tmpList = [];
                            tmpList.addAll(initialLectureList);
                            //학년 필터
                            tmpList.retainWhere((element) => classKindList.contains(element.shyr!) ? isClassTabList[classKindList.indexOf(element.shyr!)] : false);
                            print("now Filtered size : ${tmpList.length}");
                            //구분 필터(전선,전필..)
                            tmpList.retainWhere((element) => discriminateList.contains(element.subject_div!) ? isDiscTablList[discriminateList.indexOf(element.subject_div!)] : false);
                            print("now Filtered size : ${tmpList.length}");
                            //학과 필터
                            tmpList.retainWhere((element) => deptInfo == "전체" ? true : element.dept == deptInfo);
                            print("now Filtered size : ${tmpList.length}");
                            bool totalFlag = true;
                            bool initFlag = false;
                            classInfo = "";

                            for (int i = 0; i < isClassTabList.length - 1; i++) {
                              if (isClassTabList[i]) {
                                if (!initFlag) {
                                  initFlag = true;
                                  classInfo = classInfo! + (i + 1).toString();
                                } else {
                                  classInfo = "${classInfo!},${i + 1}";
                                }
                              } else {
                                totalFlag = false;
                              }
                            }
                            if (isClassTabList[isClassTabList.length - 1]) {
                              classInfo = "${classInfo!},기타";
                            }
                            if (totalFlag) classInfo = "전체";
                            if (!initFlag) {
                              print("Not Init");
                              isClassTabList = List.filled(isClassTabList.length, true);
                              classInfo = "전체";
                              Fluttertoast.showToast(msg: "1개 이상 선택해주세요");
                            } else {
                              print("Initiated size : ${tmpList.length}");
                              lectureList = tmpList;
                            }

                            Navigator.pop(context);
                          });
                        },
                        child: const Text("확인")),
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("취소")),
                  ],
                )
              ],
            );
          });
        });
  }

  showDiscDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              title: const Text("검색하고 싶은 구분을 모두 선택해주세요"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  height: 330,
                  width: 270,
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: discriminateList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  isDiscTablList[index] = !isDiscTablList[index];
                                });
                              },
                              child: Row(
                                children: [
                                  Checkbox(
                                      value: isDiscTablList[index],
                                      checkColor: Colors.redAccent,
                                      activeColor: Colors.white,
                                      fillColor: MaterialStateProperty.resolveWith(getColor),
                                      onChanged: (value) {
                                        setDialogState(() {
                                          isDiscTablList[index] = value!;
                                        });
                                      }),
                                  Text(discriminateList[index])
                                ],
                              ),
                            ),
                            divider()
                          ],
                        );
                      }),
                ),
              ]),
              actions: <Widget>[
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              isDiscTablList = List.filled(isDiscTablList.length, true);
                            },
                          );
                        },
                        child: const Text("전체 선택")),
                    TextButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              isDiscTablList = List.filled(isDiscTablList.length, false);
                            },
                          );
                        },
                        child: const Text("전체 해제")),
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          //구분, 학과 에 대한 필터링을 먼저 적용하고 난 후에
                          //필터링 해야 함
                          setState(() {
                            List<Lecture> tmpList = [];
                            tmpList.addAll(initialLectureList);
                            //학년 필터
                            tmpList.retainWhere((element) => classKindList.contains(element.shyr!) ? isClassTabList[classKindList.indexOf(element.shyr!)] : false);
                            //구분 필터(전선,전필..)
                            tmpList.retainWhere((element) => discriminateList.contains(element.subject_div!) ? isDiscTablList[discriminateList.indexOf(element.subject_div!)] : false);
                            //학과 필터
                            tmpList.retainWhere((element) => deptInfo == "전체" ? true : element.dept == deptInfo);
                            discriminateInfo = "";
                            bool initFlag = false;
                            int trueCnt = 0;
                            for (int i = 0; i < isDiscTablList.length; i++) {
                              if (isDiscTablList[i]) {
                                trueCnt++;
                                if (trueCnt > 2) continue;
                                if (!initFlag) {
                                  initFlag = true;
                                  discriminateInfo = discriminateList[i];
                                } else {
                                  discriminateInfo = "${discriminateInfo!},${discriminateList[i]}";
                                }
                              }
                            }
                            if (trueCnt == isDiscTablList.length) {
                              discriminateInfo = "전체";
                            } else if (trueCnt > 2) {
                              discriminateInfo = "${discriminateInfo!}외${trueCnt - 2}개";
                            }
                            if (!initFlag) {
                              isDiscTablList = List.filled(isDiscTablList.length, true);
                              discriminateInfo = "전체";
                              Fluttertoast.showToast(msg: "1개 이상 선택해주세요");
                            } else {
                              lectureList = tmpList;
                            }
                            Navigator.pop(context);
                          });
                        },
                        child: const Text("확인")),
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("취소")),
                  ],
                )
              ],
            );
          });
        });
  }

  showDeptDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
                scrollable: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                title: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          setDialogState(
                            () {
                              isUpper ? Navigator.pop(context) : isUpper = true;
                            },
                          );
                        },
                        icon: isUpper ? const Icon(FontAwesomeIcons.x) : const Icon(Icons.arrow_back_ios_new)),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(isUpper ? "대학을 선택해주세요" : "학과를 선택해주세요"),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 330,
                        width: 270,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(10),
                            itemCount: isUpper ? deptList.length : deptList[deptSubIndex].deptNameList!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        if (isUpper) {
                                          if (deptList[index].upperName == "전체") {
                                            setState(() {
                                              List<Lecture> tmpList = [];
                                              tmpList.addAll(initialLectureList);
                                              //학년 필터
                                              tmpList.retainWhere((element) => classKindList.contains(element.shyr!) ? isClassTabList[classKindList.indexOf(element.shyr!)] : false);
                                              //구분 필터(전선,전필..)
                                              tmpList
                                                  .retainWhere((element) => discriminateList.contains(element.subject_div!) ? isDiscTablList[discriminateList.indexOf(element.subject_div!)] : false);
                                              lectureList = tmpList;
                                              deptInfo = "전체";
                                              Navigator.pop(context);
                                            });
                                          } else {
                                            isUpper = false;
                                            deptSubIndex = index;
                                          }
                                        } else {
                                          isUpper = true;
                                          setState(() {
                                            //Filtering
                                            List<Lecture> tmpList = [];
                                            tmpList.addAll(initialLectureList);
                                            //학년 필터
                                            tmpList.retainWhere((element) => classKindList.contains(element.shyr!) ? isClassTabList[classKindList.indexOf(element.shyr!)] : false);
                                            //구분 필터(전선,전필..)
                                            tmpList.retainWhere((element) => discriminateList.contains(element.subject_div!) ? isDiscTablList[discriminateList.indexOf(element.subject_div!)] : false);
                                            //학과 필터
                                            tmpList.retainWhere((element) => element.dept == deptList[deptSubIndex].deptNameList![index]);
                                            lectureList = tmpList;

                                            deptInfo = deptList[deptSubIndex].deptNameList![index];
                                          });

                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                    child: Text(isUpper ? deptList[index].upperName : deptList[deptSubIndex].deptNameList![index]),
                                  ),
                                  divider()
                                ],
                              );
                            }),
                      )
                    ],
                  ),
                ));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                  padding: const EdgeInsets.only(left: 20),
                  onPressed: () {
                    setState(() {
                      isFilter = !isFilter;
                      lectureList = initialLectureList;
                      if (isFilter) {
                        searchTec.text = "";
                      }
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    prefixIcon: const Icon(Icons.search, color: Colors.lightBlue),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                    ),
                    hintText: "과목 이름을 입력해주세요",
                    hintStyle: const TextStyle(fontSize: 14),
                  ),
                  controller: searchTec,
                  onChanged: (value) {
                    setState(() {
                      isFilter = false;
                      List<Lecture> tmpList = [];
                      tmpList.addAll(initialLectureList);
                      tmpList.retainWhere((element) => value.isEmpty ? true : element.subjectname!.contains(value));
                      lectureList = tmpList;
                    });
                  },
                ),
              ),
            ],
          ),
          Visibility(
              visible: isFilter,
              child: const SizedBox(
                height: 10,
              )),
          Visibility(
              visible: isFilter,
              child: Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: (Row(children: [
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          showGradeDialog();
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ))),
                        child: Text("학년:${classInfo}")),
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        showDiscDialog();
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ))),
                      child: Text("구분:${discriminateInfo}"),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          showDeptDialog();
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ))),
                        child: Text("학과:${deptInfo}")),
                  ])),
                ),
              )),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            thickness: 1,
          ),
          Expanded(
              child: lectureList.isNotEmpty
                  ? ListView.builder(
                      // padding: EdgeInsets.all(20),
                      itemCount: lectureList.length,
                      itemBuilder: (context, index) {
                        return lectureComponent(lecture: lectureList[index], num: index);
                      })
                  : const Center(
                      child: Text("불러온 과목이 없습니다"),
                    ))
        ],
      ),
    );
  }
}
