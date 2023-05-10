import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/group_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class FriendGroupScreen extends ConsumerStatefulWidget {
  const FriendGroupScreen({super.key});

  @override
  ConsumerState<FriendGroupScreen> createState() => _FriendGroupScreenState();
}

class _FriendGroupScreenState extends ConsumerState<FriendGroupScreen> {
  var baseUri = '43.201.208.100:8080';
  late Future<Unwrap> UnwrapData;

  Future<Unwrap> getMyGroup(String? jwtToken) async {
    var url = Uri.http(baseUri, '/group/getMyGroup');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    dynamic data;
    if (response.statusCode == 200) {
      print('getmygroupsuccess');
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
      data = Unwrap.fromJson(parsedJson);
    } else {
      print('fail ${response.statusCode}');
    }
    return data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var jwtToken = ref.read(tokensProvider.notifier).state[0];
    UnwrapData = getMyGroup(jwtToken);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '친구',
                  ),
                  OutlinedButton(onPressed: () {}, child: const Text('추가'))
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              height: 250,
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Container(
                        height: 40,
                        color: Colors.amber,
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                    itemCount: 10),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('모임'),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('생성'),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              height: 250,
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: UnwrapData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var groupList = snapshot.data!.data;
                      return ListView.separated(
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupDetailScreen(
                                        groupData: groupList[index],
                                      ),
                                    ));
                              },
                              child: SizedBox(
                                height: 40,
                                child: Text(groupList![index]['groupName']),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 5,
                              ),
                          itemCount: snapshot.data!.data!.length);
                    } else {
                      return const Text('??');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
