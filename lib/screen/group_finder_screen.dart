import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:emptysaver_fe/screen/invitation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class GroupFinderScreen extends ConsumerStatefulWidget {
  const GroupFinderScreen({super.key});

  @override
  ConsumerState<GroupFinderScreen> createState() => _GroupFinderScreenState();
}

class _GroupFinderScreenState extends ConsumerState<GroupFinderScreen> {
  String? jwtToken;
  var baseUri = '43.201.208.100:8080';
  Future<List<Group>>? allGroupData;
  Future<List<Group>> getAllGroup() async {
    var url = Uri.http(baseUri, '/group/getAllGroup');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes))['data'] as List;
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get allgroupdata');
    }
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    allGroupData = getAllGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('그룹 찾기'),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvitationScreen(),
                          ));
                    },
                    child: const Text('조회'),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search))
                ],
              )
            ],
          ),
          SizedBox(
            height: 650,
            child: FutureBuilder(
              future: allGroupData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupFinderDetailScreen(
                                  id: snapshot.data![index].groupId),
                            ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5),
                        ),
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.group,
                                size: 50,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(snapshot.data![index].groupName!),
                                  Text(snapshot.data![index].oneLineInfo!),
                                  Text(snapshot.data![index].categoryLabel!),
                                  Text(
                                      '${snapshot.data![index].nowMember!} / ${snapshot.data![index].maxMember!}'),
                                ],
                              )
                            ],
                          ),
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
            ),
          ),
        ],
      ),
    );
  }
}
