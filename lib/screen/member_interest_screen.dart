import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/screen/login_screen_new_style.dart';
import 'package:emptysaver_fe/screen/group_detail_screen.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InterestScreen extends ConsumerStatefulWidget {
  String? firebaseToken;
  String? userEmail;
  InterestScreen(
      {super.key, required this.firebaseToken, required this.userEmail});

  @override
  ConsumerState<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends ConsumerState<InterestScreen> {
  // var jwtToken = AutoLoginController.to.state[0];
  var baseUri = '43.201.208.100:8080';
  late Future<List<FullCategoryInfo>> fullCategoryListFuture;
  List<bool> isTab = [];
  var isSelected;
  List<FullCategoryInfo> fullCategoryInfo = [];
  Future<List<FullCategoryInfo>> getFullCategoryInfo() async {
    print("called getFull");
    var url = Uri.http(baseUri, '/category/getAllList');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("got data");
      var rawData =
          jsonDecode(utf8.decode(response.bodyBytes))['result'] as List;
      print("!!!!!!rawData!!!!: $rawData");
      var data = rawData.map((e) => FullCategoryInfo.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get categoryData');
    }
  }

  void sendInterest() async {
    // print("infoList ${fullCategoryInfo}");
    List<FullCategoryInfo> infoList = [];
    for (int i = 0; i < fullCategoryInfo.length; i++) {
      infoList.add(FullCategoryInfo());
      infoList[i].type = fullCategoryInfo[i].type;
      infoList[i].typeName = fullCategoryInfo[i].typeName;
      infoList[i].tagList = [];
      for (int j = 0; j < fullCategoryInfo[i].tagList!.length; j++) {
        if (isSelected[i][j]) {
          print("select Value: ${fullCategoryInfo[i].tagList![j]}");
          infoList[i].tagList!.add(fullCategoryInfo[i].tagList![j]);
        }
      }
    }
    print("body : $infoList");
    List jsonList = infoList.map((e) => e.toJson()).toList();
    var postBody = <String, dynamic>{
      'email': widget.userEmail,
      'formList': jsonList
    };

    var url = Uri.http(baseUri, '/category/interest');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(postBody),
    );
    if (response.statusCode == 200) {
      print('groupaddsuccess');
      print(response.body);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewLoginScreen(
              firebaseToken: widget.firebaseToken,
            ),
          )); //group 디테일 페이지로 라우팅바꿀것
    } else {
      var result = jsonDecode(utf8.decode(response.bodyBytes));
      Fluttertoast.showToast(msg: '${result['message']}');
    }
  }

  @override
  void initState() {
    super.initState();
    fullCategoryListFuture = getFullCategoryInfo();
    fullCategoryListFuture.then((value) => setState(
          () {
            isTab = List.filled(value.length, false);
            isSelected = List.generate(value.length,
                (index) => List.filled(value[index].tagList!.length, false));
            fullCategoryInfo = value;
          },
        ));
  }

  categoryComponent(
      {required FullCategoryInfo categoryInfo, required int num}) {
    var tags = categoryInfo.tagList as List;
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                setState(() {
                  isTab[num] = !isTab[num];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 50,
                    ),
                    Text(categoryInfo.typeName!),
                    Icon(FontAwesomeIcons.angleDown),
                  ],
                ),
              )),
          Visibility(
              visible: isTab[num],
              child: Container(
                margin: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  // scrollDirection: Axis.horizontal,
                  child: Wrap(
                    children: tags.map((tag) {
                      int currentIndex = tags.indexOf(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected[num][currentIndex] =
                                !isSelected[num][currentIndex];
                          });
                          print("tab tab");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 12.0),
                          margin:
                              const EdgeInsets.only(right: 8.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isSelected[num][currentIndex]
                                  ? Colors.lightBlueAccent
                                  : Colors.blue,
                            ),
                            color: isSelected[num][currentIndex]
                                ? Colors.lightBlue
                                : Colors.white,
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                                color: isSelected[num][currentIndex]
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded),
      //     onPressed: () {
      //       // Navigator.of(context).maybePop();
      //       Navigator.pop(context, true);
      //     },
      //   ),
      // ),
      body: Column(children: [
        const SizedBox(
          height: 50,
          child: Center(
            child: Text("평소에 관심있는 분야를 모두 선택해주세요 !"),
          ),
        ),
        Expanded(
            child: fullCategoryInfo.length > 0
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      return categoryComponent(
                          categoryInfo: fullCategoryInfo[index], num: index);
                    },
                    itemCount: fullCategoryInfo.length,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )),
        SizedBox(
          height: 30,
        ),
        OutlinedButton(
            onPressed: () {
              print("clicked!");
              print(isSelected);
              sendInterest();
            },
            child: Text("선택 완료"))
      ]),
    );
  }
}
