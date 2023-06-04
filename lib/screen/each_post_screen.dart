import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/custom_icon_e_s_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  var jwtToken = AutoLoginController.to.state[0];
  var baseUri = '43.201.208.100:8080';
  late Future<Map<String, dynamic>> postDetailFuture;
  var commentTec = TextEditingController();
  // int commentId = 0;

  @override
  void initState() {
    super.initState();
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

  _setTag(bool amIOwner, bool amIWriter) {
    if (amIOwner)
      return const Text(
        "   (그룹장)",
        style: TextStyle(color: Colors.blue, fontSize: 14),
      );
    else if (amIWriter)
      const Text(
        "   (내 댓글)",
        style: TextStyle(color: Colors.blue, fontSize: 14),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        // bottomSheet: Container(
        //   height: 40,
        //   color: Colors.amber,
        // ),
        body: Column(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 15, top: 10, bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${snapshot.data!['title']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        '${snapshot.data!['content']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
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
                                              commentList[index]['childList']
                                                  as List;
                                          bool hasChild =
                                              (childCommentList.isNotEmpty);
                                          return Column(
                                            children: [
                                              if (index != 0)
                                                Divider(
                                                  thickness: 1.0,
                                                ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 5, left: 10),
                                                height: 110,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          FontAwesomeIcons
                                                              .comment,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          '${parentComment['writerName']}',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        _setTag(
                                                            parentComment[
                                                                'isOwner'],
                                                            parentComment[
                                                                'amIWriter'])
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(parentComment['text']),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${parentComment['dateTime'].toString().substring(0, 10)} ${parentComment['dateTime'].toString().substring(11, 19)}',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[500],
                                                              fontSize: 14),
                                                        ),
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      var childCommentTec =
                                                                          TextEditingController();
                                                                      return AlertDialog(
                                                                          insetPadding: EdgeInsets.all(
                                                                              10),
                                                                          title:
                                                                              const Text(
                                                                            '대댓글 남기기',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                          ),
                                                                          content:
                                                                              Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                            height:
                                                                                135,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                                              children: [
                                                                                TextField(
                                                                                  controller: childCommentTec,
                                                                                  decoration: InputDecoration(hintText: "대댓글을 입력해주세요", hintStyle: TextStyle(color: Colors.grey[500]), border: InputBorder.none),
                                                                                  maxLines: 3,
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.centerRight,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      OutlinedButton(
                                                                                          onPressed: () {
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          style: OutlinedButton.styleFrom(
                                                                                            side: BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                          ),
                                                                                          child: Text(
                                                                                            "취소",
                                                                                            style: TextStyle(color: const Color.fromARGB(255, 72, 72, 72)),
                                                                                          )),
                                                                                      SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      OutlinedButton(
                                                                                          onPressed: () async {
                                                                                            {
                                                                                              var url = Uri.http(baseUri, '/board/addPostComment');
                                                                                              var response = await http.post(url,
                                                                                                  headers: {
                                                                                                    'authorization': 'Bearer $jwtToken',
                                                                                                    'Content-Type': 'application/json; charset=UTF-8'
                                                                                                  },
                                                                                                  body: jsonEncode({
                                                                                                    'groupId': widget.groupId,
                                                                                                    'parentCommentId': parentComment['commentId'],
                                                                                                    'postId': widget.postId,
                                                                                                    'text': childCommentTec.text,
                                                                                                  }));
                                                                                              if (response.statusCode == 200) {
                                                                                                print(utf8.decode(response.bodyBytes));
                                                                                                // commentTec.clear();
                                                                                                Navigator.pop(context);
                                                                                                setState(() {
                                                                                                  postDetailFuture = getPost();
                                                                                                });
                                                                                              } else {
                                                                                                print(utf8.decode(response.bodyBytes));
                                                                                                return;
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                          child: const Text('완료')),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ));
                                                                    },
                                                                  );
                                                                },
                                                                child: Text(
                                                                  "대댓글",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          500],
                                                                      fontSize:
                                                                          14),
                                                                )),
                                                            Visibility(
                                                              visible: snapshot
                                                                          .data![
                                                                      'amIOwner'] ||
                                                                  parentComment[
                                                                      'amIWriter'],
                                                              child: Row(
                                                                children: [
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        var updateTec =
                                                                            TextEditingController(text: parentComment['text']);
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              AlertDialog(
                                                                            insetPadding:
                                                                                EdgeInsets.all(10),
                                                                            title:
                                                                                Text(
                                                                              "댓글 수정",
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                            ),
                                                                            content:
                                                                                Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: 135,
                                                                              child: Column(
                                                                                children: [
                                                                                  TextField(
                                                                                    controller: updateTec,
                                                                                    decoration: const InputDecoration(border: InputBorder.none),
                                                                                    maxLines: 3,
                                                                                  ),
                                                                                  Align(
                                                                                    alignment: Alignment.centerRight,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        OutlinedButton(
                                                                                            onPressed: () {
                                                                                              Navigator.pop(context);
                                                                                            },
                                                                                            style: OutlinedButton.styleFrom(
                                                                                              side: BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                            ),
                                                                                            child: Text(
                                                                                              "취소",
                                                                                              style: TextStyle(color: const Color.fromARGB(255, 72, 72, 72)),
                                                                                            )),
                                                                                        SizedBox(
                                                                                          width: 10,
                                                                                        ),
                                                                                        OutlinedButton(
                                                                                            onPressed: () async {
                                                                                              var url = Uri.http(baseUri, '/board/updateComment');
                                                                                              var response = await http.put(url,
                                                                                                  headers: {
                                                                                                    'authorization': 'Bearer $jwtToken',
                                                                                                    'Content-Type': 'application/json; charset=UTF-8'
                                                                                                  },
                                                                                                  body: jsonEncode({
                                                                                                    'commentId': parentComment['commentId'],
                                                                                                    'text': updateTec.text,
                                                                                                  }));
                                                                                              if (response.statusCode == 200) {
                                                                                                setState(() {
                                                                                                  print(utf8.decode(response.bodyBytes));
                                                                                                  Navigator.pop(context);
                                                                                                  // Navigator.pop(context);
                                                                                                  postDetailFuture = getPost();
                                                                                                });
                                                                                              } else {
                                                                                                print(utf8.decode(response.bodyBytes));
                                                                                                return;
                                                                                              }
                                                                                            },
                                                                                            child: const Text('수정'))
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        '수정',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[500],
                                                                            fontSize: 14),
                                                                      )),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) => AlertDialog(
                                                                              insetPadding: EdgeInsets.all(10),
                                                                              title: const Center(
                                                                                child: Text(
                                                                                  "정말 삭제하시겠습니까?",
                                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                                ),
                                                                              ),
                                                                              content: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  OutlinedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      style: OutlinedButton.styleFrom(
                                                                                        side: BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                      ),
                                                                                      child: const Text(
                                                                                        "아니오",
                                                                                        style: TextStyle(color: const Color.fromARGB(255, 72, 72, 72)),
                                                                                      )),
                                                                                  const SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  OutlinedButton(
                                                                                      onPressed: () async {
                                                                                        var url = Uri.http(baseUri, '/board/deleteComment/${parentComment['commentId']}');
                                                                                        var response = await http.delete(url, headers: {
                                                                                          'authorization': 'Bearer $jwtToken'
                                                                                        });
                                                                                        if (response.statusCode == 200) {
                                                                                          print(utf8.decode(response.bodyBytes));
                                                                                          Fluttertoast.showToast(msg: '삭제되었습니다');
                                                                                          setState(() {
                                                                                            postDetailFuture = getPost();
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        } else {
                                                                                          print(utf8.decode(response.bodyBytes));
                                                                                          print('실패');
                                                                                        }
                                                                                      },
                                                                                      child: const Text('예'))
                                                                                ],
                                                                              )),
                                                                        );
                                                                        // final result = await FlutterPlatformAlert.showCustomAlert(
                                                                        //     windowTitle:
                                                                        //         'title',
                                                                        //     text:
                                                                        //         'text',
                                                                        //     positiveButtonTitle:
                                                                        //         'yy',
                                                                        //     negativeButtonTitle:
                                                                        //         'nn');
                                                                        // print(
                                                                        //     'result : $result');
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        '삭제',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey[500],
                                                                            fontSize: 14),
                                                                      ))
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                  visible: hasChild,
                                                  child: Column(
                                                    children: [
                                                      for (int i = 0;
                                                          i <
                                                              childCommentList
                                                                  .length;
                                                          i++)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 0, 0, 0),
                                                          height: 105,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  //대댓글
                                                                  const Icon(
                                                                    CustomIconES
                                                                        .level_down,
                                                                    size: 20,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                    '${childCommentList[i]['writerName']}',
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  _setTag(
                                                                      childCommentList[
                                                                              i]
                                                                          [
                                                                          'isOwner'],
                                                                      childCommentList[
                                                                              i]
                                                                          [
                                                                          'amIWriter']),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                  childCommentList[
                                                                          i]
                                                                      ['text']),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    '${childCommentList[i]['dateTime'].toString().substring(0, 10)} ${childCommentList[i]['dateTime'].toString().substring(11, 19)}',
                                                                    style: TextStyle(
                                                                        color: Colors.grey[
                                                                            500],
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Visibility(
                                                                        visible:
                                                                            snapshot.data!['amIOwner'] ||
                                                                                childCommentList[i]['amIWriter'],
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  var updateTec = TextEditingController(text: childCommentList[i]['text']);
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => AlertDialog(
                                                                                      insetPadding: EdgeInsets.all(10),
                                                                                      title: Text(
                                                                                        "댓글 수정",
                                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                                      ),
                                                                                      content: Container(
                                                                                        width: MediaQuery.of(context).size.width,
                                                                                        height: 135,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            TextField(
                                                                                              controller: updateTec,
                                                                                              decoration: const InputDecoration(border: InputBorder.none),
                                                                                              maxLines: 3,
                                                                                            ),
                                                                                            Align(
                                                                                              alignment: Alignment.centerRight,
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                                children: [
                                                                                                  OutlinedButton(
                                                                                                      onPressed: () {
                                                                                                        Navigator.pop(context);
                                                                                                      },
                                                                                                      style: OutlinedButton.styleFrom(
                                                                                                        side: BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                                      ),
                                                                                                      child: Text(
                                                                                                        "취소",
                                                                                                        style: TextStyle(color: const Color.fromARGB(255, 72, 72, 72)),
                                                                                                      )),
                                                                                                  SizedBox(
                                                                                                    width: 10,
                                                                                                  ),
                                                                                                  OutlinedButton(
                                                                                                      onPressed: () async {
                                                                                                        var url = Uri.http(baseUri, '/board/updateComment');
                                                                                                        var response = await http.put(url,
                                                                                                            headers: {
                                                                                                              'authorization': 'Bearer $jwtToken',
                                                                                                              'Content-Type': 'application/json; charset=UTF-8'
                                                                                                            },
                                                                                                            body: jsonEncode({
                                                                                                              'commentId': childCommentList[i]['commentId'],
                                                                                                              'text': updateTec.text,
                                                                                                            }));
                                                                                                        if (response.statusCode == 200) {
                                                                                                          setState(() {
                                                                                                            print(utf8.decode(response.bodyBytes));
                                                                                                            postDetailFuture = getPost();
                                                                                                            Navigator.pop(context);
                                                                                                            // Navigator.pop(context);
                                                                                                          });
                                                                                                        } else {
                                                                                                          print(utf8.decode(response.bodyBytes));
                                                                                                          return;
                                                                                                        }
                                                                                                      },
                                                                                                      child: const Text('수정'))
                                                                                                ],
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  '수정',
                                                                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                                                                )),
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => AlertDialog(
                                                                                        insetPadding: EdgeInsets.all(10),
                                                                                        title: const Center(
                                                                                          child: Text(
                                                                                            "정말 삭제하시겠습니까?",
                                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                                          ),
                                                                                        ),
                                                                                        content: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                          children: [
                                                                                            OutlinedButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                style: OutlinedButton.styleFrom(
                                                                                                  side: BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                                ),
                                                                                                child: const Text(
                                                                                                  "아니오",
                                                                                                  style: TextStyle(color: const Color.fromARGB(255, 72, 72, 72)),
                                                                                                )),
                                                                                            const SizedBox(
                                                                                              width: 10,
                                                                                            ),
                                                                                            OutlinedButton(
                                                                                                onPressed: () async {
                                                                                                  var url = Uri.http(baseUri, '/board/deleteComment/${childCommentList[i]['commentId']}');
                                                                                                  var response = await http.delete(url, headers: {
                                                                                                    'authorization': 'Bearer $jwtToken'
                                                                                                  });
                                                                                                  if (response.statusCode == 200) {
                                                                                                    print(utf8.decode(response.bodyBytes));
                                                                                                    Fluttertoast.showToast(msg: '삭제되었습니다');
                                                                                                    setState(() {
                                                                                                      postDetailFuture = getPost();
                                                                                                    });
                                                                                                    Navigator.pop(context);
                                                                                                  } else {
                                                                                                    print(utf8.decode(response.bodyBytes));
                                                                                                    print('실패');
                                                                                                  }
                                                                                                },
                                                                                                child: const Text('예'))
                                                                                          ],
                                                                                        )),
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  '삭제',
                                                                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                                                                ))
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ))
                                            ],
                                          );
                                        },
                                      )
                                    : const Text('댓글 없음'),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: titleTec,
                                ),
                                TextField(
                                  controller: contentTec,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  minLines: null,
                                  // expands: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                OutlinedButton(
                                    onPressed: () async {
                                      var url = Uri.http(
                                          baseUri, '/board/updatePost');
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
                            ),
                          ),
                        );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            if (widget.mode == 'read')
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
                            var url =
                                Uri.http(baseUri, '/board/addPostComment');
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
                              print(utf8.decode(response.bodyBytes));
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
