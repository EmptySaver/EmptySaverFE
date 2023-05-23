import 'dart:convert';

import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class EachPostScreen extends ConsumerStatefulWidget {
  int? postId;
  int? groupId;
  String mode;

  EachPostScreen({super.key, this.postId, this.mode = 'read', this.groupId});

  @override
  ConsumerState<EachPostScreen> createState() => _EachPostScreenState();
}

class _EachPostScreenState extends ConsumerState<EachPostScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  late Future<Map<String, dynamic>> postDetailFuture;
  var commentTec = TextEditingController();

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
      // bottomSheet: Container(
      //   height: 40,
      //   color: Colors.amber,
      // ),
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
                  var commentList = snapshot.data!['comments'] as List;
                  return (widget.mode == 'read')
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text('${snapshot.data!['title']}'),
                                Text('${snapshot.data!['content']}'),
                                const Divider(thickness: 1.5),
                                (commentList.isNotEmpty)
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: commentList.length,
                                        itemBuilder: (context, index) {
                                          var parentComment =
                                              commentList[index]['parent'];
                                          var childCommentList =
                                              commentList[index]['childList'];
                                          return Container(
                                            padding: const EdgeInsets.all(5),
                                            height: 100,
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        width: 1,
                                                        color: Colors.grey))),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text('아이콘,이름'),
                                                    ButtonBar(
                                                      children: [
                                                        IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            onPressed: () {},
                                                            icon: const Icon(Icons
                                                                .add_comment_rounded)),
                                                        IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            onPressed: () {},
                                                            icon: const Icon(Icons
                                                                .more_vert_rounded)),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                Text(parentComment['text']),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    '${parentComment['dateTime'].toString().substring(0, 10)} ${parentComment['dateTime'].toString().substring(11, 19)}'),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : const Text('댓글 없음'),
                              ],
                            ),
                          ),
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration:
                            const InputDecoration(hintText: '댓글을 입력하세요'),
                        controller: commentTec,
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          var url = Uri.http(baseUri, '/board/addPostComment');
                          var response = await http.post(url,
                              headers: {
                                'authorization': 'Bearer $jwtToken',
                                'Content-Type':
                                    'application/json; charset=UTF-8'
                              },
                              body: jsonEncode({
                                'groupId': widget.groupId,
                                'parentCommentId': -1,
                                'postId': widget.postId,
                                'text': commentTec.text,
                              }));
                          if (response.statusCode == 200) {
                            print('댓글');
                            commentTec.clear();
                            setState(() {
                              postDetailFuture = getPost();
                            });
                          } else {
                            print(utf8.decode(response.bodyBytes));
                          }
                        },
                        icon: const Icon(Icons.send_rounded))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
