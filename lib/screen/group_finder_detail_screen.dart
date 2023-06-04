import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:emptysaver_fe/element/custom_icon_e_s_icons.dart';

class GroupFinderDetailScreen extends ConsumerStatefulWidget {
  int? id;

  GroupFinderDetailScreen({super.key, this.id});

  @override
  ConsumerState<GroupFinderDetailScreen> createState() => _GroupFinderDetailScreenState();
}

class _GroupFinderDetailScreenState extends ConsumerState<GroupFinderDetailScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  late Future<Group> groupDetailFuture;
  var commentTec = TextEditingController();

  Future<Group> getGroupDetail() async {
    var url = Uri.http(baseUri, '/group/getGroupDetail/${widget.id}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var data = Group.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      // print("Got Data: ${data.commentList?[0]['parent']}");
      // print("Got Data: ${data.commentList![0]['childList']}");
      print("comment Size : ${data.commentList?.length}");
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('그룹 디테일정보 가져오기 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    groupDetailFuture = getGroupDetail();
  }

  _setButton(Group groupDetail) {
    if (groupDetail.memberStatus == "in") {
      return const Center(child: Text("가입된 그룹 입니다"));
    } else if (groupDetail.memberStatus == "mid") {
      return const Center(child: Text("가입신청을 보냈습니다"));
    } else {
      return Align(
        alignment: Alignment.center,
        child: OutlinedButton(
          onPressed: () async {
            var url = Uri.http(baseUri, '/group/sendRequest/${groupDetail.groupId}');
            var response = await http.post(url, headers: {'authorization': 'Bearer $jwtToken'});
            if (response.statusCode == 200) {
              Fluttertoast.showToast(msg: '가입 신청 완료');
              // Navigator.pop(context);
              setState(() {
                groupDetailFuture = getGroupDetail();
              });
            } else {
              print(utf8.decode(response.bodyBytes));
            }
          },
          child: const Text('가입 신청'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    List<CommentList>? commentList = groupDetail.commentList;
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${groupDetail.groupName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                ),
                                Text('(${groupDetail.nowMember} / ${groupDetail.maxMember})')
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Align(
                            //   alignment: Alignment.centerLeft,
                            //   child: ,
                            // ),
                            Text(
                              '${groupDetail.oneLineInfo}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 20),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(width: 65, child: Text("공개 여부", style: TextStyle(color: Colors.grey[500], fontSize: 16))),
                                const SizedBox(
                                  width: 10,
                                ),
                                (isPublic!)
                                    ? const Text(
                                        "공개",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    : const Text(
                                        '비공개',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(width: 65, child: Text("실명 여부", style: TextStyle(color: Colors.grey[500], fontSize: 16))),
                                const SizedBox(
                                  width: 10,
                                ),
                                (isAnonymous!)
                                    ? const Text(
                                        "익명 그룹",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    : const Text(
                                        '실명 그룹',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 65, child: Text("카테고리", style: TextStyle(color: Colors.grey[500], fontSize: 16))),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${groupDetail.categoryName}',
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: 65, child: Text("세부 장르", style: TextStyle(color: Colors.grey[500], fontSize: 16))),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${groupDetail.categoryLabel}',
                                  style: const TextStyle(fontSize: 16),
                                )
                              ],
                            ),

                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              '${groupDetail.groupDescription}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //widget s
                            _setButton(groupDetail),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 2.0,
                              color: Colors.blue,
                            ),
                            (commentList != null)
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: commentList.length,
                                    itemBuilder: (context, index) {
                                      var parentComment = commentList[index].parent;
                                      List<ChildList>? childCommentList = commentList[index].childList;
                                      bool hasChild = (childCommentList != null);
                                      return Column(
                                        children: [
                                          if (index != 0)
                                            const Divider(
                                              thickness: 1.0,
                                            ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 5),
                                            // height: 105,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      FontAwesomeIcons.comment,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      '${parentComment!.writerName}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    if (parentComment.isOwner!)
                                                      const Text(
                                                        "   (그룹장)",
                                                        style: TextStyle(color: Colors.blue, fontSize: 14),
                                                      )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(parentComment.text!),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${parentComment.dateTime.toString().substring(0, 10)} ${parentComment.dateTime.toString().substring(11, 19)}',
                                                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                                    ),
                                                    Row(
                                                      children: [
                                                        TextButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  var childCommentTec = TextEditingController();
                                                                  return AlertDialog(
                                                                      insetPadding: const EdgeInsets.all(10),
                                                                      title: const Text(
                                                                        '대댓글 남기기',
                                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                      ),
                                                                      content: SizedBox(
                                                                        width: MediaQuery.of(context).size.width,
                                                                        height: 135,
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                          children: [
                                                                            TextField(
                                                                              controller: childCommentTec,
                                                                              decoration:
                                                                                  InputDecoration(hintText: "대댓글을 입력해주세요", hintStyle: TextStyle(color: Colors.grey[500]), border: InputBorder.none),
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
                                                                                        side: const BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                      ),
                                                                                      child: const Text(
                                                                                        "취소",
                                                                                        style: TextStyle(color: Color.fromARGB(255, 72, 72, 72)),
                                                                                      )),
                                                                                  const SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  OutlinedButton(
                                                                                      onPressed: () async {
                                                                                        {
                                                                                          var url = Uri.http(baseUri, '/board/addGroupComment');
                                                                                          var response = await http.post(url,
                                                                                              headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                                                              body: jsonEncode({
                                                                                                'groupId': groupDetail.groupId,
                                                                                                'parentCommentId': parentComment.commentId,
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
                                                              style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                                            )),
                                                        Visibility(
                                                          visible: groupDetail.amIOwner! || parentComment.amIWriter!,
                                                          child: Row(
                                                            children: [
                                                              TextButton(
                                                                  onPressed: () {
                                                                    var updateTec = TextEditingController(text: parentComment.text);
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (context) => AlertDialog(
                                                                        insetPadding: const EdgeInsets.all(10),
                                                                        title: const Text(
                                                                          "댓글 수정",
                                                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                        ),
                                                                        content: SizedBox(
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
                                                                                          side: const BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                        ),
                                                                                        child: const Text(
                                                                                          "취소",
                                                                                          style: TextStyle(color: Color.fromARGB(255, 72, 72, 72)),
                                                                                        )),
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                    OutlinedButton(
                                                                                        onPressed: () async {
                                                                                          var url = Uri.http(baseUri, '/board/updateComment');
                                                                                          var response = await http.put(url,
                                                                                              headers: {'authorization': 'Bearer $jwtToken', 'Content-Type': 'application/json; charset=UTF-8'},
                                                                                              body: jsonEncode({
                                                                                                'commentId': parentComment.commentId,
                                                                                                'text': updateTec.text,
                                                                                              }));
                                                                                          if (response.statusCode == 200) {
                                                                                            setState(() {
                                                                                              print(utf8.decode(response.bodyBytes));
                                                                                              groupDetailFuture = getGroupDetail();
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
                                                                          insetPadding: const EdgeInsets.all(10),
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
                                                                                    side: const BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                  ),
                                                                                  child: const Text(
                                                                                    "아니오",
                                                                                    style: TextStyle(color: Color.fromARGB(255, 72, 72, 72)),
                                                                                  )),
                                                                              const SizedBox(
                                                                                width: 10,
                                                                              ),
                                                                              OutlinedButton(
                                                                                  onPressed: () async {
                                                                                    var url = Uri.http(baseUri, '/board/deleteComment/${parentComment.commentId}');
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
                                                )
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                              visible: hasChild,
                                              child: Column(
                                                children: [
                                                  for (int i = 0; i < childCommentList!.length; i++)
                                                    Container(
                                                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                      // decoration: BoxDecoration(
                                                      //     color: Colors
                                                      //         .grey.shade200),
                                                      height: 100,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                CustomIconES.level_down,
                                                                size: 20,
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                '${childCommentList[i].writerName}',
                                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                              if (childCommentList[i].isOwner!)
                                                                const Text(
                                                                  "   (그룹장)",
                                                                  style: TextStyle(color: Colors.blue, fontSize: 14),
                                                                )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(childCommentList[i].text!),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                '${childCommentList[i].dateTime.toString().substring(0, 10)} ${childCommentList[i].dateTime.toString().substring(11, 19)}',
                                                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Visibility(
                                                                    visible: groupDetail.amIOwner! || childCommentList[i].amIWriter!,
                                                                    child: Row(
                                                                      children: [
                                                                        TextButton(
                                                                            onPressed: () {
                                                                              var updateTec = TextEditingController(text: childCommentList[i].text);
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) => AlertDialog(
                                                                                  insetPadding: const EdgeInsets.all(10),
                                                                                  title: const Text(
                                                                                    "댓글 수정",
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                                  ),
                                                                                  content: SizedBox(
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
                                                                                                    side: const BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                                  ),
                                                                                                  child: const Text(
                                                                                                    "취소",
                                                                                                    style: TextStyle(color: Color.fromARGB(255, 72, 72, 72)),
                                                                                                  )),
                                                                                              const SizedBox(
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
                                                                                                          'commentId': childCommentList[i].commentId,
                                                                                                          'text': updateTec.text,
                                                                                                        }));
                                                                                                    if (response.statusCode == 200) {
                                                                                                      setState(() {
                                                                                                        print(utf8.decode(response.bodyBytes));
                                                                                                        groupDetailFuture = getGroupDetail();
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
                                                                                    insetPadding: const EdgeInsets.all(10),
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
                                                                                              side: const BorderSide(color: Color.fromARGB(192, 181, 181, 181), width: 1.5),
                                                                                            ),
                                                                                            child: const Text(
                                                                                              "아니오",
                                                                                              style: TextStyle(color: Color.fromARGB(255, 72, 72, 72)),
                                                                                            )),
                                                                                        const SizedBox(
                                                                                          width: 10,
                                                                                        ),
                                                                                        OutlinedButton(
                                                                                            onPressed: () async {
                                                                                              var url = Uri.http(baseUri, '/board/deleteComment/${childCommentList[i].commentId}');
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
                                : const Center(
                                    child: Text('댓글 없음'),
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
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 1000,
                        // expands: true,
                        keyboardType: TextInputType.multiline,
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
            ],
          ),
        ),
      ),
    );
  }

  // bool isTextFieldExpanded = true;
  // void _handleTextChanged(String text) {
  // if (text. > maxLength) { // maxLength는 텍스트 필드가 고정된 높이를 가지기로 결정하는 길이입니다.
  //   isTextFieldExpanded = false;
  // } else {
  //   isTextFieldExpanded = true;
  // }
}
