import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class GroupFinderDetailScreen extends ConsumerStatefulWidget {
  int? id;

  GroupFinderDetailScreen({super.key, this.id});

  @override
  ConsumerState<GroupFinderDetailScreen> createState() => _GroupFinderDetailScreenState();
}

class _GroupFinderDetailScreenState extends ConsumerState<GroupFinderDetailScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  late Future<Group> groupDetailFuture;
  var commentTec = TextEditingController();

  Future<Group> getGroupDetail() async {
    var url = Uri.http(baseUri, '/group/getGroupDetail/${widget.id}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var data = Group.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('그룹 디테일정보 가져오기 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    groupDetailFuture = getGroupDetail();
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
              future: groupDetailFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var groupDetail = snapshot.data;
                  var isPublic = groupDetail!.isPublic;
                  var isAnonymous = groupDetail.isAnonymous;
                  var commentList = groupDetail.commentList as List;
                  return Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text('${groupDetail.groupName} (${groupDetail.nowMember} / ${groupDetail.maxMember})'),
                          Text('${groupDetail.oneLineInfo}'),
                          (isPublic!) ? const Text("공개 그룹") : const Text('비공개 그룹'),
                          (isAnonymous!) ? const Text("익명 그룹") : const Text('실명 그룹'),
                          Text('${groupDetail.categoryLabel}'),
                          Text('${groupDetail.groupDescription}'),
                          const Divider(
                            thickness: 1.5,
                          ),
                          (commentList.isNotEmpty)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: commentList.length,
                                  itemBuilder: (context, index) {
                                    var parentComment = commentList[index]['parent'];
                                    var childCommentList = commentList[index]['childList'] as List;
                                    bool hasChild = (childCommentList.isNotEmpty);
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          height: 100,
                                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text('아이콘,이름'),
                                                  Text('${parentComment['commentId']}'),
                                                  ButtonBar(
                                                    children: [
                                                      IconButton(
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(),
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                var childCommentTec = TextEditingController();
                                                                return SimpleDialog(
                                                                  title: const Text('대댓글'),
                                                                  children: [
                                                                    TextField(
                                                                      controller: childCommentTec,
                                                                    ),
                                                                    OutlinedButton(
                                                                        onPressed: () async {
                                                                          {
                                                                            var url = Uri.http(baseUri, '/board/addGroupComment');
                                                                            var response = await http.post(url,
                                                                                headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                                                body: jsonEncode({
                                                                                  'groupId': groupDetail.groupId,
                                                                                  'parentCommentId': parentComment['commentId'],
                                                                                  'text': childCommentTec.text,
                                                                                }));
                                                                            if (response.statusCode == 200) {
                                                                              print(utf8.decode(response.bodyBytes));
                                                                              // commentTec.clear();
                                                                              Navigator.pop(context);
                                                                              setState(() {
                                                                                groupDetailFuture = getGroupDetail();
                                                                              });
                                                                            } else {
                                                                              print(utf8.decode(response.bodyBytes));
                                                                              return;
                                                                            }
                                                                          }
                                                                        },
                                                                        child: const Text('입력'))
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: const Icon(Icons.add_comment_rounded)),
                                                      IconButton(
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(),
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => SimpleDialog(
                                                                children: [
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        var updateTec = TextEditingController(text: parentComment['text']);
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (context) => SimpleDialog(
                                                                            children: [
                                                                              TextField(
                                                                                controller: updateTec,
                                                                                decoration: const InputDecoration(),
                                                                              ),
                                                                              OutlinedButton(
                                                                                  onPressed: () async {
                                                                                    var url = Uri.http(baseUri, '/board/updateComment');
                                                                                    var response = await http.put(url,
                                                                                        headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                                                        body: jsonEncode({
                                                                                          'commentId': parentComment['commentId'],
                                                                                          'text': updateTec.text,
                                                                                        }));
                                                                                    if (response.statusCode == 200) {
                                                                                      setState(() {
                                                                                        print(utf8.decode(response.bodyBytes));
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                        groupDetailFuture = getGroupDetail();
                                                                                      });
                                                                                    } else {
                                                                                      print(utf8.decode(response.bodyBytes));
                                                                                      return;
                                                                                    }
                                                                                  },
                                                                                  child: const Text('수정'))
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: const Text('수정')),
                                                                  TextButton(
                                                                      onPressed: () async {
                                                                        var url = Uri.http(baseUri, '/board/deleteComment/${parentComment['commentId']}');
                                                                        var response = await http.delete(url, headers: {'authorization': 'Bearer $jwtToken'});
                                                                        if (response.statusCode == 200) {
                                                                          print(utf8.decode(response.bodyBytes));
                                                                          Fluttertoast.showToast(msg: '삭제되었습니다');
                                                                          setState(() {
                                                                            groupDetailFuture = getGroupDetail();
                                                                          });
                                                                          Navigator.pop(context);
                                                                        } else {
                                                                          print(utf8.decode(response.bodyBytes));
                                                                          print('실패');
                                                                        }
                                                                      },
                                                                      child: const Text('삭제'))
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          icon: const Icon(Icons.more_vert_rounded)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Text(parentComment['text']),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text('${parentComment['dateTime'].toString().substring(0, 10)} ${parentComment['dateTime'].toString().substring(11, 19)}'),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                            visible: hasChild,
                                            child: Column(
                                              children: [
                                                for (int i = 0; i < childCommentList.length; i++)
                                                  Container(
                                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                    decoration: BoxDecoration(color: Colors.grey.shade200),
                                                    height: 100,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            //대댓글
                                                            const Text('아이콘,이름'),
                                                            Text('${childCommentList[i]['commentId']}'),
                                                            ButtonBar(
                                                              children: [
                                                                IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    constraints: const BoxConstraints(),
                                                                    onPressed: () {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) {
                                                                          var childCommentTec = TextEditingController();
                                                                          return SimpleDialog(
                                                                            title: const Text('대댓글'),
                                                                            children: [
                                                                              TextField(
                                                                                controller: childCommentTec,
                                                                              ),
                                                                              OutlinedButton(
                                                                                  onPressed: () async {
                                                                                    {
                                                                                      var url = Uri.http(baseUri, '/board/addGroupComment');
                                                                                      var response = await http.post(url,
                                                                                          headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                                                          body: jsonEncode({
                                                                                            'groupId': groupDetail.groupId,
                                                                                            'parentCommentId': parentComment['commentId'],
                                                                                            'text': childCommentTec.text,
                                                                                          }));
                                                                                      if (response.statusCode == 200) {
                                                                                        print(utf8.decode(response.bodyBytes));
                                                                                        // commentTec.clear();
                                                                                        Navigator.pop(context);
                                                                                        setState(() {
                                                                                          groupDetailFuture = getGroupDetail();
                                                                                        });
                                                                                      } else {
                                                                                        print(utf8.decode(response.bodyBytes));
                                                                                        return;
                                                                                      }
                                                                                    }
                                                                                  },
                                                                                  child: const Text('입력'))
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                    icon: const Icon(Icons.add_comment_rounded)),
                                                                IconButton(
                                                                    padding: EdgeInsets.zero,
                                                                    constraints: const BoxConstraints(),
                                                                    onPressed: () {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) => SimpleDialog(
                                                                          children: [
                                                                            TextButton(
                                                                                onPressed: () {
                                                                                  var updateTec = TextEditingController(text: childCommentList[i]['text']);
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => SimpleDialog(
                                                                                      children: [
                                                                                        TextField(
                                                                                          controller: updateTec,
                                                                                          decoration: const InputDecoration(),
                                                                                        ),
                                                                                        OutlinedButton(
                                                                                            onPressed: () async {
                                                                                              var url = Uri.http(baseUri, '/board/updateComment');
                                                                                              var response = await http.put(url,
                                                                                                  headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                                                                  body: jsonEncode({
                                                                                                    'commentId': childCommentList[i]['commentId'],
                                                                                                    'text': updateTec.text,
                                                                                                  }));
                                                                                              if (response.statusCode == 200) {
                                                                                                setState(() {
                                                                                                  print(utf8.decode(response.bodyBytes));
                                                                                                  Navigator.pop(context);
                                                                                                  Navigator.pop(context);
                                                                                                  groupDetailFuture = getGroupDetail();
                                                                                                });
                                                                                              } else {
                                                                                                print(utf8.decode(response.bodyBytes));
                                                                                                return;
                                                                                              }
                                                                                            },
                                                                                            child: const Text('수정'))
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                                child: const Text('수정')),
                                                                            TextButton(
                                                                                onPressed: () async {
                                                                                  var url = Uri.http(baseUri, '/board/deleteComment/${childCommentList[i]['commentId']}');
                                                                                  print(childCommentList[i]['commentId']);
                                                                                  var response = await http.delete(
                                                                                    url,
                                                                                    headers: {'authorization': 'Bearer $jwtToken'},
                                                                                  );
                                                                                  if (response.statusCode == 200) {
                                                                                    print(utf8.decode(response.bodyBytes));
                                                                                    Fluttertoast.showToast(msg: '삭제되었습니다');
                                                                                    Navigator.pop(context);
                                                                                    setState(() {
                                                                                      groupDetailFuture = getGroupDetail();
                                                                                    });
                                                                                  } else {
                                                                                    print(utf8.decode(response.bodyBytes));
                                                                                    print('실패');
                                                                                  }
                                                                                },
                                                                                child: const Text('삭제'))
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                    icon: const Icon(Icons.more_vert_rounded)),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        Text(childCommentList[i]['text']),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text('${childCommentList[i]['dateTime'].toString().substring(0, 10)} ${childCommentList[i]['dateTime'].toString().substring(11, 19)}'),
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
                          OutlinedButton(
                            onPressed: () async {
                              var url = Uri.http(baseUri, '/group/sendRequest/${groupDetail.groupId}');
                              var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
                              if (response.statusCode == 200) {
                                Fluttertoast.showToast(msg: '가입 신청 완료');
                                Navigator.pop(context);
                              } else {
                                print(utf8.decode(response.bodyBytes));
                              }
                            },
                            child: const Text('가입하기'),
                          ),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: '댓글을 입력하세요'),
                        controller: commentTec,
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          var url = Uri.http(baseUri, '/board/addGroupComment');
                          var response = await http.post(url,
                              headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                              body: jsonEncode({
                                'groupId': widget.id,
                                'parentCommentId': -1,
                                'text': commentTec.text,
                              }));
                          if (response.statusCode == 200) {
                            print(utf8.decode(response.bodyBytes));
                            commentTec.clear();
                            setState(() {
                              groupDetailFuture = getGroupDetail();
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
