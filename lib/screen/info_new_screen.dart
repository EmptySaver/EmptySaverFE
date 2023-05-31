import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class InfoScreenNew extends ConsumerStatefulWidget {
  const InfoScreenNew({super.key});

  @override
  ConsumerState<InfoScreenNew> createState() => _InfoScreenStateNew();
}

class _InfoScreenStateNew extends ConsumerState<InfoScreenNew> {
  final TextStyle dropdownMenuItem = const TextStyle(color: Colors.black, fontSize: 18);
  final ScrollController _scrollController = ScrollController(); //스크롤 감지용

  final primary = const Color(0xff696b9e);
  final secondary = const Color(0xfff29a94);

  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  int nonSubjectPageNum = 0;
  int recruitingPageNum = 0;
  late List<Info> nonSubjectLoadedList = [];
  late List<Info> recruitingLoadedList = [];
  late Future<List<Info>> targetList;
  late bool recruitType;
  String infoTitle = " - ";
  String recruitTitle = "리쿠르팅";
  String nonSubjectTitle = "비교과";

  late Future<List<Info>> nonSubjectList;
  late Future<List<Info>> recruitingList;

  Future<List<Info>> getNonsubject() async {
    var url = Uri.http(baseUri, '/info/nonSubject/$nonSubjectPageNum');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Info.fromJson(e)).toList();

      if (data.isNotEmpty) {
        nonSubjectPageNum++;
      }

      nonSubjectLoadedList.addAll(data);
      return nonSubjectLoadedList;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get nonsubjectdata');
    }
  }

  Future<List<Info>> getRecruiting() async {
    var url = Uri.http(baseUri, '/info/recruiting/$recruitingPageNum');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Info.fromJson(e)).toList();

      if (data.isNotEmpty) {
        recruitingPageNum++;
      }

      recruitingLoadedList.addAll(data);
      print(recruitingLoadedList.length);
      return recruitingLoadedList;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get recruitingdata');
    }
  }

  scrollListener() async {
    // print('offset = ${_scrollController.offset}');

    if (_scrollController.offset == _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
      print('스크롤이 맨 바닥에 위치해서, 다음을 로드함니다.');
      setState(() {
        if (recruitType) {
          print('취업재로딩');
          recruitingList = getRecruiting();
          targetList = recruitingList;
        } else {
          print('비교과재로딩');
          nonSubjectList = getNonsubject();
          targetList = nonSubjectList;
        }
      });
    } else if (_scrollController.offset == _scrollController.position.minScrollExtent && !_scrollController.position.outOfRange) {
      print('스크롤이 맨 위에 위치해 있습니다');
    }
  }

  @override
  void initState() {
    recruitType = true;
    infoTitle = recruitTitle;
    _scrollController.addListener(() {
      scrollListener();
    });
    super.initState();
    nonSubjectList = getNonsubject();
    recruitingList = getRecruiting();

    targetList = recruitingList;
  }

  FutureBuilder getFutureBuilder() {
    return FutureBuilder(
      future: targetList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            //padding: const EdgeInsets.only(top: 80),
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            //decoration: BoxDecoration(border: Border.all()),
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,

              itemBuilder: (context, index) => Container(
                constraints: const BoxConstraints(
                  maxHeight: double.infinity,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey.shade200,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white,
                ),
                width: double.infinity,
                //height: 110,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, //알잘딱 정렬
                  children: [
                    Text(
                      '${snapshot.data![index].courseName} \n',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('신청 기간: ${snapshot.data![index].applyDate}'),
                    Text('활동 기간: ${snapshot.data![index].runDate}'),
                    Text('대상학과 : ${snapshot.data![index].targetDepartment}, 대상학년 : ${snapshot.data![index].targetGrade}',
                        textAlign: TextAlign.center
                    ),
                    //Text('${snapshot.data![index].url}'),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue,width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () async {
                        final url = Uri.parse(
                          '${snapshot.data![index].url}',
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: const Text('신청 바로가기',
                        style: TextStyle(
                          //fontFamily: 'NimbusSanL',
                          fontSize: 15,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset : false,
      //backgroundColor: const Color(0xfff0f0f0),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        targetList = recruitingList;
                        print("취업으로");
                        infoTitle = recruitTitle; //recruitType = true;

                        recruitType = !recruitType;
                      });
                    },
                    child:Container(
                      height: 60,
                      //width: double.infinity,
                      decoration: BoxDecoration(
                        //color: Colors.blue,
                          border: Border.all(color: recruitType ? Colors.blueAccent: Colors.blueGrey.shade200),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "리쿠르팅",
                            style: TextStyle(color: recruitType ? Colors.blueAccent: Colors.blueGrey.shade200, fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
              )),Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        targetList = nonSubjectList;
                        print("비교과로");
                        infoTitle = nonSubjectTitle;
                        //recruitType = false;

                        recruitType = !recruitType;
                      });
                    },
                    child: Container(
                      height: 60,
                      //width: double.infinity,
                      decoration: BoxDecoration(
                        //color: Colors.blue,
                          border: Border.all(color: recruitType ? Colors.blueGrey.shade200 : Colors.blueAccent),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "비교과",
                            style: TextStyle(color: recruitType ? Colors.blueGrey.shade200 : Colors.blueAccent,  fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                )),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(thickness: 1,),
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: getFutureBuilder()/*Stack(
                  children: <Widget>[
                    getFutureBuilder(),
                  ],
                ),*/
              ),
            ),
          )
        ],
      ),
    );
  }
}
