import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:emptysaver_fe/garbage/invitation_screen_legacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';

class GroupFinderScreen extends ConsumerStatefulWidget {
  const GroupFinderScreen({super.key});

  @override
  ConsumerState<GroupFinderScreen> createState() => _GroupFinderScreenState();
}

class _GroupFinderScreenState extends ConsumerState<GroupFinderScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];
  List<Group> initialGroupData = [];
  List<Group> groupData = [];
  bool isSearch = false;
  bool isCategorySelected = false;
  Future<List<Map<String, dynamic>>>? allCategoryFuture;
  Future<List<dynamic>>? allTagFuture;
  String? initialCategory;
  String? initialTag;
  String? categoryForTagApi;
  var searchTec = TextEditingController(text: '');

  getAllGroup() async {
    var url = Uri.http(baseUri, '/group/getAllGroup');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      print("raw: $rawData");
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      // print("got::${data[0]}");
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
    getAllGroup().then((value) => setState(
          () {
            initialGroupData = value;
            groupData = value;
          },
        ));
    allCategoryFuture = getAllCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Container(
          child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        padding: const EdgeInsets.only(left: 20),
                        onPressed: () {
                          isSearch = !isSearch;
                          setState(() {
                            if (isSearch) {
                              searchTec.text = "";
                            }

                            isCategorySelected = false;
                            groupData = initialGroupData;
                          });
                        },
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color.fromARGB(255, 25, 162, 230),
                        )),
                    Container(
                      height: 45,
                      width: 300,
                      margin: const EdgeInsets.only(left: 20),
                      child: TextField(
                        cursorColor: Colors.grey,
                        controller: searchTec,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.lightBlue),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 196, 195, 195),
                                width: 1.5),
                          ),
                          hintText: "검색할 그룹 이름을 입력해주세요",
                          hintStyle: const TextStyle(fontSize: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            print("Empty? :${value.isEmpty}");
                            print("Keyword :${value}");
                            List<Group> tmpList = [];
                            tmpList.addAll(initialGroupData);
                            tmpList.retainWhere((element) => value.isEmpty
                                ? true
                                : element.groupName!.contains(value));
                            groupData = tmpList;
                            isSearch = false;
                            isCategorySelected = false;
                            initialTag = initialCategory = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Visibility(
                visible: isSearch,
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: FutureBuilder(
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
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: const Row(
                                children: [
                                  Icon(
                                    Icons.list,
                                    size: 16,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '전체분류',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: items
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              value: initialCategory,
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
                                    setState(() {
                                      groupData = data;
                                    });
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                    throw Exception('failed to get groupData');
                                  }
                                } else {
                                  setState(() {
                                    initialCategory = "전체";
                                    groupData = initialGroupData;
                                    isCategorySelected = false;
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
                                  categoryForTagApi = jsonDecode(
                                      utf8.decode(response.bodyBytes))['type'];
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
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: 120,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.blue, width: 1.5),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                ),
                                iconSize: 14,
                                iconEnabledColor: Colors.blueAccent,
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 100,
                                  padding: null,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                  elevation: 8,
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  )),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    )),
              ),
              Visibility(
                visible: isCategorySelected,
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: FutureBuilder(
                      future: allTagFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<DropdownMenuItem> itemList = [];
                          itemList.add(const DropdownMenuItem(
                            value: "전체",
                            child: Text(
                              "전체",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ));
                          itemList.addAll(snapshot.data!
                              .map<DropdownMenuItem<String>>(
                                  (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                              .toList());
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: const Row(
                                children: [
                                  Icon(
                                    Icons.list,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '태그',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: itemList,
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
                                var response = await http.get(url, headers: {
                                  'authorization': 'Bearer $jwtToken'
                                });
                                if (response.statusCode == 200) {
                                  var rawData = jsonDecode(
                                      utf8.decode(response.bodyBytes)) as List;
                                  var data = rawData
                                      .map((e) => Group.fromJson(e))
                                      .toList();
                                  setState(() {
                                    groupData = data;
                                    initialTag = value;
                                  });
                                } else {
                                  print(utf8.decode(response.bodyBytes));
                                }
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: 100,
                                padding:
                                    const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.blue, width: 1.5),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                ),
                                iconSize: 14,
                                iconEnabledColor: Colors.blue,
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 100,
                                  padding: null,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                  elevation: 8,
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  )),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    )),
              ),
            ],
          ),
          Divider(
            color: const Color.fromARGB(255, 126, 126, 126),
          ),
          Expanded(
              child: groupData.length > 0
                  ? ListView.builder(
                      itemCount: groupData.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupFinderDetailScreen(
                                    id: groupData[index].groupId,
                                  ),
                                ));
                          },
                          child: jobComponent(job: groupData[index]),
                        );
                      })
                  : Center(
                      child: Text("조회된 그룹이 없습니다"),
                    ))
        ],
      )),
    );
  }

  jobComponent({required Group job}) {
    return Container(
      // padding: const EdgeInsets.all(10),
      // margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200),
                      child: Text(
                        job.categoryName!,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 108, 108, 108),
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200),
                      child: Text(
                        job.categoryLabel!,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 98, 98, 98),
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                Text('${job.nowMember!} / ${job.maxMember!}'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(children: [
                  SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        // child: Image.asset(job.companyLogo),
                        child: const Icon(Icons.group_add),
                      )),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.groupName!,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(job.oneLineInfo!,
                              style: TextStyle(color: Colors.grey[500])),
                        ]),
                  )
                ]),
              ),
            ],
          ),
          Divider(
            color: Color.fromARGB(255, 126, 126, 126),
          )
        ],
      ),
    );
  }
}
