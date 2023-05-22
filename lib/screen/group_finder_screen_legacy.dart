import 'dart:convert';

import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/main.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:emptysaver_fe/screen/invitation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class GroupFinderScreenOld extends ConsumerStatefulWidget {
  const GroupFinderScreenOld({super.key});

  @override
  ConsumerState<GroupFinderScreenOld> createState() =>
      _GroupFinderScreenState();
}

class _GroupFinderScreenState extends ConsumerState<GroupFinderScreenOld> {
  String? jwtToken;
  var baseUri = '43.201.208.100:8080';
  late Future<List<Group>> groupData;
  bool isSearch = false;
  bool isCategorySelected = false;
  Future<List<Map<String, dynamic>>>? allCategoryFuture;
  Future<List<dynamic>>? allTagFuture;
  String initialCategory = '전체';
  String? initialTag;
  String? categoryForTagApi;

  Future<List<Group>> getAllGroup() async {
    var url = Uri.http(baseUri, '/group/getAllGroup');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get groupData');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategory() async {
    var url = Uri.http(baseUri, '/category/getCategoryList');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var parsedJson =
          jsonDecode(utf8.decode(response.bodyBytes))['result'] as List;
      var data = parsedJson.map((e) => e as Map<String, dynamic>).toList();
      print(data);
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('카테고리 가져오기 실패');
    }
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    groupData = getAllGroup();
    allCategoryFuture = getAllCategory();
  }

  @override
  Widget build(BuildContext context) {
    print('나, 빌드');
    Future<List<Group>>? searchCategoryTeam;
    return SingleChildScrollView(
      child: Padding(
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
                    IconButton(
                        onPressed: () {
                          isSearch = !isSearch;
                          setState(() {
                            groupData = getAllGroup();
                            isCategorySelected = false;
                          });
                        },
                        icon: const Icon(Icons.search))
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              visible: isSearch,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('키워드로 검색'),
                        const SizedBox(
                          width: 20,
                        ),
                        FutureBuilder(
                          future: allCategoryFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var items = [
                                '전체',
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  snapshot.data![i]['name']!
                              ];
                              var dropItems = items
                                  .map<DropdownMenuItem<String>>(
                                      (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                  .toList();
                              var types = [
                                '전체',
                                for (int i = 0; i < snapshot.data!.length; i++)
                                  snapshot.data![i]['type']
                              ];
                              return DropdownButton<String>(
                                items: dropItems,
                                onChanged: (value) async {
                                  var query = items.indexOf(value);
                                  var url, response;
                                  if (!(value == '전체')) {
                                    url = Uri.http(baseUri,
                                        '/group/getCategoryTeam/${types[query]}');
                                    response = await http.get(url, headers: {
                                      'authorization': 'Bearer $jwtToken'
                                    });
                                    if (response.statusCode == 200) {
                                      var rawData = jsonDecode(
                                              utf8.decode(response.bodyBytes))
                                          as List;
                                      var data = rawData
                                          .map((e) => Group.fromJson(e))
                                          .toList();
                                      searchCategoryTeam = Future(() => data);
                                      setState(() {
                                        groupData = searchCategoryTeam!;
                                      });
                                    } else {
                                      print(utf8.decode(response.bodyBytes));
                                      throw Exception(
                                          'failed to get groupData');
                                    }
                                  } else {
                                    setState(() {
                                      groupData = getAllGroup();
                                    });
                                  }
                                  var tags = [];
                                  tags.isEmpty
                                      ? initialTag = null
                                      : initialTag =
                                          tags[0]; // 수정하긴 했는데.. 더 깊게 공부해야 할듯
                                  url = Uri.http(baseUri,
                                      '/category/getLabels/${types[query]}');
                                  response = await http.get(url, headers: {
                                    'authorization': 'Bearer $jwtToken'
                                  });
                                  if (response.statusCode == 200) {
                                    categoryForTagApi = jsonDecode(utf8
                                        .decode(response.bodyBytes))['type'];
                                    tags = jsonDecode(utf8.decode(
                                        response.bodyBytes))['result'] as List;
                                    allTagFuture = Future(() => tags);
                                    // print(allTagFuture);
                                    setState(() {
                                      initialCategory = value!;
                                      // initialTag = tags[0];
                                      isCategorySelected = true;
                                    });
                                  }
                                },
                                value: initialCategory,
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                        Visibility(
                            visible: isCategorySelected,
                            child: FutureBuilder(
                              future: allTagFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var dropItems = snapshot.data!
                                      .map<DropdownMenuItem<String>>(
                                          (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ))
                                      .toList();
                                  return DropdownButton<String>(
                                    items: dropItems,
                                    value: initialTag,
                                    onChanged: (value) async {
                                      initialTag = value!;
                                      print(categoryForTagApi);
                                      print(value);
                                      var url = Uri.http(
                                          baseUri, '/group/getLabelTeam', {
                                        'categoryName': categoryForTagApi,
                                        'label': utf8.decode(utf8.encode(value))
                                      });
                                      var response = await http.get(url,
                                          headers: {
                                            'authorization': 'Bearer $jwtToken'
                                          });
                                      if (response.statusCode == 200) {
                                        var rawData = jsonDecode(
                                                utf8.decode(response.bodyBytes))
                                            as List;
                                        var data = rawData
                                            .map((e) => Group.fromJson(e))
                                            .toList();
                                        setState(() {
                                          groupData = Future(() => data);
                                        });
                                      } else {
                                        print(utf8.decode(response.bodyBytes));
                                      }
                                    },
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ]),
            ),
            SizedBox(
              height: 650,
              child: FutureBuilder(
                future: groupData,
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
      ),
    );
  }
}
