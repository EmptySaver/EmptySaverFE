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
  ConsumerState<GroupFinderDetailScreen> createState() =>
      _GroupFinderDetailScreenState();
}

class _GroupFinderDetailScreenState
    extends ConsumerState<GroupFinderDetailScreen> {
  late var jwtToken;
  var baseUri = '43.201.208.100:8080';
  late Future<Group> groupDetailFuture;

  Future<Group> getGroupDetail() async {
    var url = Uri.http(baseUri, '/group/getGroupDetail/${widget.id}');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
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
        child: FutureBuilder(
          future: groupDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var groupDetail = snapshot.data;
              var isPublic = groupDetail!.isPublic;
              var isAnonymous = groupDetail.isAnonymous;
              return Center(
                child: Column(
                  children: [
                    Text(
                        '${groupDetail.groupName} (${groupDetail.nowMember} / ${groupDetail.maxMember})'),
                    Text('${groupDetail.oneLineInfo}'),
                    (isPublic!) ? const Text("공개 그룹") : const Text('비공개 그룹'),
                    (isAnonymous!) ? const Text("익명 그룹") : const Text('실명 그룹'),
                    Text('${groupDetail.categoryLabel}'),
                    Text('${groupDetail.groupDescription}'),
                    const Text('댓글'),
                    OutlinedButton(
                      onPressed: () async {
                        var url = Uri.http(baseUri,
                            '/group/sendRequest/${groupDetail.groupId}');
                        var response = await http.post(url,
                            headers: {'authorization': 'Bearer $jwtToken'});
                        if (response.statusCode == 200) {
                          Fluttertoast.showToast(msg: '가입 신청 완료');
                          Navigator.pop(context);
                        } else {
                          print(utf8.decode(response.bodyBytes));
                        }
                      },
                      child: const Text('가입하기'),
                    )
                  ],
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
