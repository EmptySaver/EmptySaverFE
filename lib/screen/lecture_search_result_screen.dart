import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class LectureSearchResultScreen extends ConsumerStatefulWidget {
  List<Lecture>? resultList;

  LectureSearchResultScreen({super.key, this.resultList});

  @override
  ConsumerState<LectureSearchResultScreen> createState() =>
      _LectureSearchResultScreenState();
}

class _LectureSearchResultScreenState
    extends ConsumerState<LectureSearchResultScreen> {
  var baseUri = '43.201.208.100:8080';
  late var jwtToken;

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.resultList;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: data!.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(border: Border.all()),
              height: 100,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data[index].subjectname}'),
                      Text('${data[index].prof_nm}'),
                      Text('${data[index].class_nm}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('${data[index].shyr}학년'),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('${data[index].subject_div}'),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('${data[index].credit}학점'),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('${data[index].dept}'),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      OutlinedButton(
                          onPressed: () async {
                            var url = Uri.http(
                                baseUri,
                                '/subject/saveSubjectToMember',
                                {'subjectId': '${data[index].id}'});
                            var response = await http.post(url,
                                headers: {'authorization': 'Bearer $jwtToken'});
                            if (response.statusCode == 200) {
                              Fluttertoast.showToast(msg: '추가되었습니다');
                            } else {
                              print(utf8.decode(response.bodyBytes));
                            }
                          },
                          child: const Text('추가')),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
