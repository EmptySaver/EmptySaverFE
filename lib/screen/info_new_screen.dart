import 'dart:convert';

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
  final TextStyle dropdownMenuItem =
  const TextStyle(color: Colors.black, fontSize: 18);
  final ScrollController _scrollController = ScrollController();  //스크롤 감지용

  final primary = const Color(0xff696b9e);
  final secondary = const Color(0xfff29a94);

  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  int nonSubjectPageNum = 0;
  int recruitingPageNum = 0;
  late List<Info> nonSubjectLoadedList =  [];
  late List<Info> recruitingLoadedList =  [];
  late Future<List<Info>> targetList;
  late bool recruitType;
  String infoTitle = " - ";
  String recruitTitle = "리쿠르팅";
  String nonSubjectTitle = "비교과";

  late Future<List<Info>> nonSubjectList;
  late Future<List<Info>> recruitingList;

  Future<List<Info>> getNonsubject() async {
    var url = Uri.http(baseUri, '/info/nonSubject/$nonSubjectPageNum');
    var response =
    await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Info.fromJson(e)).toList();

      if(data.isNotEmpty){
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
    var response =
    await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Info.fromJson(e)).toList();

      if(data.isNotEmpty){
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

    if (_scrollController.offset == _scrollController.position.maxScrollExtent
        && !_scrollController.position.outOfRange) {
      print('스크롤이 맨 바닥에 위치해서, 다음을 로드함니다.');
      setState(() {
        if(recruitType){
          print('취업재로딩');
          recruitingList = getRecruiting();
          targetList = recruitingList;
        }else{
          print('비교과재로딩');
          nonSubjectList = getNonsubject();
          targetList = nonSubjectList;
        }
      });

    } else if (_scrollController.offset == _scrollController.position.minScrollExtent
        && !_scrollController.position.outOfRange) {
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
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    nonSubjectList = getNonsubject();
    recruitingList = getRecruiting();

    targetList = recruitingList;
  }

  FutureBuilder getFutureBuilder(){
    return FutureBuilder(
      future: targetList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.only(top: 80),
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: BoxDecoration(border: Border.all()),
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,

              itemBuilder: (context, index) => Container(
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                ),
                decoration: BoxDecoration(
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text('신청 기간: ${snapshot.data![index].applyDate}'),
                    Text('활동 기간: ${snapshot.data![index].runDate}'),
                    Text(
                        '대상학과 : ${snapshot.data![index].targetDepartment}, 대상학년 : ${snapshot.data![index].targetGrade}'),
                    //Text('${snapshot.data![index].url}'),
                    ElevatedButton(
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
                      child: const Text('신청 바로가기'),
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
      backgroundColor: const Color(0xfff0f0f0),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              getFutureBuilder(),
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        infoTitle,
                        style: TextStyle(color: Colors.white, fontSize: 30,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.fromLTRB(5, 18, 0, 0),
                  child: Visibility(
                    visible: !recruitType,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          targetList = recruitingList;
                          print("취업으로");
                          infoTitle = recruitTitle; //recruitType = true;

                          recruitType = !recruitType;
                        });
                      },
                      child: Text('<-리크루팅',
                        style: TextStyle(fontSize: 22,color: Colors.white70,fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue, onPrimary: Colors.white),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 18, 5, 0),
                    child: Visibility(
                      visible: recruitType,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            targetList = nonSubjectList;
                            print("비교과로");
                            infoTitle = nonSubjectTitle;
                            //recruitType = false;

                            recruitType = !recruitType;
                          });
                        },
                        child: Text('비교과 ->',
                          style: TextStyle(fontSize: 22,color: Colors.white70,fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue, onPrimary: Colors.white),
                      ),
                    ),
                ),
              ),
              //원래 여기
              /*
              Column(
                children: <Widget>[
                  const SizedBox(
                    height: 65,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      child: TextField(
                        // controller: TextEditingController(text: locations[0]),
                        cursorColor: Theme.of(context).primaryColor,
                        style: dropdownMenuItem,
                        decoration: const InputDecoration(
                            hintText: "비교과 찾기",
                            hintStyle: TextStyle(
                                color: Colors.black38, fontSize: 16),
                            prefixIcon: Material(
                              elevation: 0.0,
                              borderRadius:
                              BorderRadius.all(Radius.circular(30)),
                              child: Icon(Icons.search),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 13)),
                      ),
                    ),
                  ),
                ],
              )*/
            ],
          ),
        ),
      ),
    );
  }

}
