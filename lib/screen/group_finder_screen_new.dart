import 'dart:convert';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/element/factory_fromjson.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:emptysaver_fe/screen/invitation_screen.dart';
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
  late Future<List<Group>> groupData;
  bool isSearch = false;
  bool isCategorySelected = false;
  Future<List<Map<String, dynamic>>>? allCategoryFuture;
  Future<List<dynamic>>? allTagFuture;
  String? initialCategory;
  String? initialTag;
  String? categoryForTagApi;

  Future<List<Group>> getAllGroup() async {
    var url = Uri.http(baseUri, '/group/getAllGroup');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      print("raw: $rawData");
      var data = rawData.map((e) => Group.fromJson(e)).toList();
      print("got::${data[0]}");
      return data;
    } else {
      print(utf8.decode(response.bodyBytes));
      throw Exception('failed to get groupData');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategory() async {
    var url = Uri.http(baseUri, '/category/getCategoryList');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    if (response.statusCode == 200) {
      var parsedJson = jsonDecode(utf8.decode(response.bodyBytes))['result'] as List;
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
    groupData = getAllGroup();
    allCategoryFuture = getAllCategory();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Group>>? searchCategoryTeam;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 179, 186, 224),
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
                            // groupData = getAllGroup();
                            isCategorySelected = false;
                          });
                        },
                        icon: const Icon(
                          Icons.filter_list,
                          color: Color.fromARGB(255, 66, 25, 230),
                        )),
                    Container(
                      height: 45,
                      width: 250,
                      margin: const EdgeInsets.only(left: 20),
                      child: TextField(
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                          hintText: "검색기능 구현 ..?",
                          hintStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.white60),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InvitationScreen(),
                            ));
                      },
                      child: const Text('조회'),
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
                          var items = ['전체', for (int i = 0; i < snapshot.data!.length; i++) snapshot.data![i]['name']!];
                          var dropItems = items
                              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList();
                          var types = ['전체', for (int i = 0; i < snapshot.data!.length; i++) snapshot.data![i]['type']];
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: const Row(
                                children: [
                                  Icon(
                                    Icons.list,
                                    size: 16,
                                    color: Colors.white,
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
                                        color: Colors.white,
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
                                            color: Colors.white,
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
                                  url = Uri.http(baseUri, '/group/getCategoryTeam/${types[query]}');
                                  response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
                                  if (response.statusCode == 200) {
                                    var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
                                    var data = rawData.map((e) => Group.fromJson(e)).toList();
                                    searchCategoryTeam = Future(() => data);
                                    setState(() {
                                      groupData = searchCategoryTeam!;
                                    });
                                  } else {
                                    print(utf8.decode(response.bodyBytes));
                                    throw Exception('failed to get groupData');
                                  }
                                } else {
                                  setState(() {
                                    initialCategory = "전체";
                                    groupData = getAllGroup();
                                    isCategorySelected = false;
                                  });
                                }
                                var tags = [];
                                tags.isEmpty ? initialTag = null : initialTag = tags[0]; // 수정하긴 했는데.. 더 깊게 공부해야 할듯
                                url = Uri.http(baseUri, '/category/getLabels/${types[query]}');
                                response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
                                if (response.statusCode == 200) {
                                  categoryForTagApi = jsonDecode(utf8.decode(response.bodyBytes))['type'];
                                  tags = jsonDecode(utf8.decode(response.bodyBytes))['result'] as List;
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
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.black26,
                                  ),
                                  color: const Color.fromARGB(255, 210, 132, 243),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                ),
                                iconSize: 14,
                                iconEnabledColor: Color.fromARGB(255, 255, 255, 255),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 200,
                                  padding: null,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.deepPurple,
                                  ),
                                  elevation: 8,
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility: MaterialStateProperty.all(true),
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
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ));
                          itemList.addAll(snapshot.data!
                              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                                    color: Colors.white,
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
                                        color: Colors.white,
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
                                var url = Uri.http(baseUri, '/group/getLabelTeam', {'categoryName': categoryForTagApi, 'label': utf8.decode(utf8.encode(value))});
                                var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
                                if (response.statusCode == 200) {
                                  var rawData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
                                  var data = rawData.map((e) => Group.fromJson(e)).toList();
                                  setState(() {
                                    groupData = Future(() => data);
                                    initialTag = value;
                                  });
                                } else {
                                  print(utf8.decode(response.bodyBytes));
                                }
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: 120,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.black26,
                                  ),
                                  color: const Color.fromARGB(255, 210, 132, 243),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_forward_ios_outlined,
                                ),
                                iconSize: 14,
                                iconEnabledColor: Color.fromARGB(255, 255, 255, 255),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 200,
                                  padding: null,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: Colors.deepPurple,
                                  ),
                                  elevation: 8,
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility: MaterialStateProperty.all(true),
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
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: groupData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupFinderDetailScreen(
                                      id: snapshot.data![index].groupId,
                                    ),
                                  ));
                            },
                            child: jobComponent(job: snapshot.data![index]),
                          );
                        });
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          )
        ],
      )),
    );
  }

  jobComponent({required Group job}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromARGB(255, 251, 246, 255), boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ]),
      child: Column(
        children: [
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
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(job.groupName!, style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(job.oneLineInfo!, style: TextStyle(color: Colors.grey[500])),
                    ]),
                  )
                ]),
              ),
              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       job.isMyFav = !job.isMyFav;
              //     });
              //   },
              //   child: AnimatedContainer(
              //       height: 35,
              //       padding: EdgeInsets.all(5),
              //       duration: Duration(milliseconds: 300),
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(12),
              //           border: Border.all(
              //             color: job.isMyFav
              //                 ? Colors.red.shade100
              //                 : Colors.grey.shade300,
              //           )),
              //       child: Center(
              //           child: job.isMyFav
              //               ? Icon(
              //                   Icons.favorite,
              //                   color: Colors.red,
              //                 )
              //               : Icon(
              //                   Icons.favorite_outline,
              //                   color: Colors.grey.shade600,
              //                 ))),
              // )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                      child: Text(
                        job.categoryName!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade200),
                      child: Text(
                        job.categoryLabel!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    // Container(
                    //   padding:
                    //       EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12),
                    //       color: Color(
                    //               int.parse("0xff${job.experienceLevelColor}"))
                    //           .withAlpha(20)),
                    //   child: Text(
                    //     job.experienceLevel,
                    //     style: TextStyle(
                    //         color: Color(
                    //             int.parse("0xff${job.experienceLevelColor}"))),
                    //   ),
                    // )
                  ],
                ),
                // Text(
                //   job.timeAgo,
                //   style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                // )
                Text('${job.nowMember!} / ${job.maxMember!}'),
              ],
            ),
          )
        ],
      ),
    );
  }
}



// SizedBox(
//   height: 100,
//   child: Row(
//     children: [
//       IconButton(
//           onPressed: () {
//             isSearch = !isSearch;
//             setState(() {
//               groupData = getAllGroup();
//               isCategorySelected = false;
//             });
//           },
//           icon: const Icon(Icons.filter)),
//       Container(
//         height: 45,
//         margin: EdgeInsets.all(30),
//         // padding: EdgeInsets.all(10),
//         child: TextField(
//           cursorColor: Colors.grey,
//           decoration: InputDecoration(
//             contentPadding:
//                 EdgeInsets.symmetric(horizontal: 20, vertical: 0),
//             filled: true,
//             fillColor: Colors.grey.shade200,
//             prefixIcon: Icon(Icons.search, color: Colors.grey),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(50),
//                 borderSide: BorderSide.none),
//             hintText: "Search e.g Software Developer",
//             hintStyle: TextStyle(fontSize: 14),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

// Visibility(
//     visible: isSearch,
//     child: Row(
//       children: [Text("point")],
//     )),
