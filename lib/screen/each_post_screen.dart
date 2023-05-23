import 'dart:convert';

import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class EachPostScreen extends ConsumerStatefulWidget {
  int? postId;
  String mode;

  EachPostScreen({super.key, this.postId, this.mode = 'read'});

  @override
  ConsumerState<EachPostScreen> createState() => _EachPostScreenState();
}

class _EachPostScreenState extends ConsumerState<EachPostScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  late Future<Map<String, dynamic>> postDetailFuture;

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    postDetailFuture = getPost();
  }

  Future<Map<String, dynamic>> getPost() async {
    var url = Uri.http(baseUri, '/board/getPost/${widget.postId}');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('공지 내용 불러오기 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FutureBuilder(
              future: postDetailFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var titleTec =
                      TextEditingController(text: snapshot.data!['title']);
                  var contentTec =
                      TextEditingController(text: snapshot.data!['content']);
                  return (widget.mode == 'read')
                      ? Column(
                          children: [
                            Text('${snapshot.data!['title']}'),
                            Text('${snapshot.data!['content']}')
                          ],
                        )
                      : Column(
                          children: [
                            TextField(
                              controller: titleTec,
                            ),
                            TextField(
                              controller: contentTec,
                            ),
                            OutlinedButton(
                                onPressed: () async {
                                  var url =
                                      Uri.http(baseUri, '/board/updatePost');
                                  var response = await http.put(url,
                                      headers: {
                                        'authorization': 'Bearer $jwtToken',
                                        'Content-Type':
                                            'application/json; charset=UTF-8'
                                      },
                                      body: jsonEncode({
                                        'title': titleTec.text,
                                        'content': contentTec.text,
                                        'postId': widget.postId
                                      }));
                                  if (response.statusCode == 200) {
                                    Fluttertoast.showToast(msg: '수정되었습니다');
                                    // Navigator.pop(context, '');
                                    int count = 2;
                                    Navigator.popUntil(
                                        context, (route) => count-- <= 0);
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                    return;
                                  }
                                },
                                child: const Text('수정하기')),
                          ],
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
