import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:flutter/material.dart';

class LectureSearchResultScreen extends StatefulWidget {
  List<Lecture>? resultList;

  LectureSearchResultScreen({super.key, this.resultList});

  @override
  State<LectureSearchResultScreen> createState() =>
      _LectureSearchResultScreenState();
}

class _LectureSearchResultScreenState extends State<LectureSearchResultScreen> {
  @override
  Widget build(BuildContext context) {
    var data = widget.resultList;
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: data!.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 80,
            child: Text('${data[index].subjectname}'),
          );
        },
      ),
    );
  }
}
