import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class InfoScreen extends ConsumerStatefulWidget {
  const InfoScreen({super.key});

  @override
  ConsumerState<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends ConsumerState<InfoScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  int nonSubjectPageNum = 0;
  int recruitingPageNum = 0;
  late Future<List<Info>> nonSubjectList;
  late Future<List<Info>> recruitingList;

  Future<List<Info>> getNonsubject() async {
    var url = Uri.http(baseUri, '/info/nonSubject/$nonSubjectPageNum');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Info.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get nonsubjectdata');
    }
  }

  Future<List<Info>> getRecruiting() async {
    var url = Uri.http(baseUri, '/info/nonSubject/$recruitingPageNum');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Info.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get recruitingdata');
    }
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    nonSubjectList = getNonsubject();
    recruitingList = getRecruiting();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Column(
          children: [
            const Text('비교과'),
            FutureBuilder(
              future: nonSubjectList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    height: 650,
                    decoration: BoxDecoration(border: Border.all()),
                    child: ListView.builder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => Container(
                        height: 200,
                        decoration: BoxDecoration(border: Border.all()),
                        child: Column(
                          children: [
                            Text('${snapshot.data![index].courseName}'),
                            Text('${snapshot.data![index].applyDate}'),
                            Text('${snapshot.data![index].runDate}'),
                            Text(
                                '대상학과 : ${snapshot.data![index].targetDepartment}, 대상학년 : ${snapshot.data![index].targetGrade}'),
                            Text('${snapshot.data![index].url}'),
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
            )
          ],
        ),
      ),
    );
  }
}
