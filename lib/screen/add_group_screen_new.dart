import 'package:emptysaver_fe/element/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class AddGroupScreen extends ConsumerStatefulWidget {
  String? type;
  String? name;
  AddGroupScreen({super.key, this.type, this.name});
  @override
  ConsumerState<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends ConsumerState<AddGroupScreen> {
  var baseUri = '43.201.208.100:8080';
  var dateTec = TextEditingController(text: '');
  var nameTec = TextEditingController(text: '');
  var bodyTec = TextEditingController(text: '');
  var oneLineTec = TextEditingController(text: '');
  var numTec = TextEditingController(text: '');
  late var tagList;
  bool isPublic = false;
  bool isAnonymous = false;
  String? selectedTag;
  late var jwtToken;
  int activeIndex = -1;

  Future<dynamic> getTag(String? jwtToken) async {
    var url = Uri.http(baseUri, '/category/getLabels/${widget.type}');
    var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
    var tags = parsedJson['result'];
    return tags;
  }

  @override
  void initState() {
    super.initState();
    jwtToken = AutoLoginController.to.state[0];
    tagList = getTag(jwtToken);
  }

  Widget _buildTagList(BuildContext context) {
    return FutureBuilder(
        future: tagList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.data as List;
            return Container(
                child: SizedBox(
              height: 50,
              width: 400,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  children: items.map((item) {
                    int currentIndex = items.indexOf(item);
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (activeIndex == currentIndex) {
                              activeIndex = -1;
                              selectedTag = null;
                            } else {
                              activeIndex = currentIndex;
                              selectedTag = items[activeIndex];
                              print("select : $selectedTag");
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                          margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(width: 1.5, color: activeIndex == currentIndex ? Colors.blue : Colors.blue //const Color.fromRGBO(195, 228, 243, 1),
                                  ),
                              color: activeIndex == currentIndex ? Colors.blue : Colors.white //const Color.fromRGBO(196, 220, 227, 1),
                              ),
                          child: Text(
                            item,
                            style: TextStyle(
                              color: activeIndex == currentIndex ? Colors.white : Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ));
          } else {
            return const SizedBox();
          }
        });
  }

  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          const SizedBox(
            height: 30.0,
          ),
          // const CircleAvatar(
          //   maxRadius: 50,
          //   backgroundColor: Colors.transparent,
          //   child: PNetworkImage(origami),
          // ),
          const SizedBox(
            height: 20.0,
          ),
          _buildAddGroupForm(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: <Widget>[
          //     FloatingActionButton(
          //       mini: true,
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       backgroundColor: Colors.blue,
          //       child: const Icon(Icons.arrow_back),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  Container _buildAddGroupForm() {
    List<bool> selections = [];
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          Container(
            //height: 800,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(40.0)), border: Border.all(color: Colors.blueAccent)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 50.0,
                ),
                Text(
                  "${widget.name!} 그룹 생성",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: nameTec,
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          hintText: "그룹명",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.groups_3,
                            color: Colors.blue,
                          )),
                      keyboardType: TextInputType.text,
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: oneLineTec,
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          hintText: "한줄 설명",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.note_alt,
                            color: Colors.blue,
                          )),
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: bodyTec,
                      style: const TextStyle(color: Colors.blue),
                      maxLines: 4,
                      decoration: InputDecoration(
                          hintText: "\n그룹 설명",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.description_rounded,
                            color: Colors.blue,
                          )),
                      keyboardType: TextInputType.text,
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextField(
                      controller: numTec,
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          hintText: "최대 인원",
                          hintStyle: TextStyle(color: Colors.blue.shade200),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          )),
                      keyboardType: TextInputType.number,
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Divider(
                    color: Colors.blue.shade400,
                  ),
                ),
                _buildTagList(context),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      value: isPublic,
                      onChanged: (bool? value) {
                        setState(() {
                          isPublic = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('공개 그룹'),
                    const SizedBox(
                      width: 30,
                    ),
                    Checkbox(
                      checkColor: Colors.white,
                      value: isAnonymous,
                      onChanged: (bool? value) {
                        setState(() {
                          isAnonymous = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('실명 사용 그룹'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                  onPressed: () async {
                    if (nameTec.text.isEmpty) {
                      Fluttertoast.showToast(msg: '그룹명을 입력해주세요');
                      return;
                    }
                    if (oneLineTec.text.isEmpty) {
                      Fluttertoast.showToast(msg: '한줄 설명을 입력해주세요');
                      return;
                    }
                    if (bodyTec.text.isEmpty) {
                      Fluttertoast.showToast(msg: '한줄 설명을 입력해주세요');
                      return;
                    }
                    if (numTec.text.isEmpty) {
                      Fluttertoast.showToast(msg: '그룹 정원을 입력해주세요');
                      return;
                    }
                    if (selectedTag == null) {
                      Fluttertoast.showToast(msg: '그룹 태그를 선택해주세요');
                      return;
                    }
                    var postBody = <String, dynamic>{
                      'groupName': nameTec.text,
                      'oneLineInfo': oneLineTec.text,
                      'groupDescription': bodyTec.text,
                      'maxMember': numTec.text,
                      'isPublic': isPublic,
                      'isAnonymous': isAnonymous,
                      'categoryName': widget.type,
                      'labelName': selectedTag,
                    };
                    var url = Uri.http(baseUri, '/group/make');
                    var response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json', 'authorization': 'Bearer $jwtToken'},
                      body: jsonEncode(postBody),
                    );
                    if (response.statusCode == 200) {
                      print('groupaddsuccess');
                      print(response.body);
                      Navigator.pushNamedAndRemoveUntil(context, '/bar', (route) => false);
                    } else {
                      var result = jsonDecode(utf8.decode(response.bodyBytes));
                      Fluttertoast.showToast(msg: '${result['message']}');
                    }
                  },
                  child: const Text("생성"),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(0.0, -30),
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.blue.shade600,
                  child: const Icon(Icons.group_add),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        title: const Text(
          '그룹 생성',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _buildPageContent(context),
    );
  }
}
