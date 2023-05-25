import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class MakePostScreen extends ConsumerStatefulWidget {
  Group? groupdata;

  MakePostScreen({super.key, this.groupdata});

  @override
  ConsumerState<MakePostScreen> createState() => _MakePostScreenState();
}

class _MakePostScreenState extends ConsumerState<MakePostScreen> {
  var jwtToken = AutoLoginController.to.state[0];
  var baseUri = '43.201.208.100:8080';
  var titleTec = TextEditingController();
  var contentTec = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: '제목',
                ),
                controller: titleTec,
              ),
              SizedBox(
                height: 550,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: '내용',
                  ),
                  controller: contentTec,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () async {
                    var url = Uri.http(baseUri, '/board/makePost');
                    var response = await http.post(url,
                        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                        body: jsonEncode({'title': titleTec.text, 'content': contentTec.text, 'groupId': widget.groupdata!.groupId}));
                    print(widget.groupdata!.groupId);
                    if (response.statusCode == 200) {
                      Fluttertoast.showToast(msg: '작성되었습니다');
                      Navigator.pop(context, '');
                    } else {
                      Fluttertoast.showToast(msg: '글쓰기 오류');
                      print(utf8.decode(response.bodyBytes));
                      return;
                    }
                  },
                  child: const Text('쓰기'))
            ],
          ),
        ),
      ),
    );
  }
}
