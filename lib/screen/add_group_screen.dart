import 'package:emptysaver_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<dynamic> getTag(String? jwtToken) async {
    var url = Uri.http(baseUri, '/category/getLabels/${widget.type}');
    var response =
        await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
    var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
    var tags = parsedJson['result'];
    return tags;
  }

  @override
  void initState() {
    super.initState();
    jwtToken = ref.read(tokensProvider.notifier).state[0];
    tagList = getTag(jwtToken);
  }

  @override
  Widget build(BuildContext context) {
    // var jwtToken = ref.read(tokensProvider.notifier).state[0];
    List<bool> selections = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 생성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: 250,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.name!,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: nameTec,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.title),
                    labelText: '그룹명',
                  ),
                ),
                TextField(
                  controller: oneLineTec,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.description_outlined),
                    labelText: '한줄 설명',
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  maxLines: 5,
                  controller: bodyTec,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.text_snippet_outlined),
                    labelText: '그룹 설명',
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: numTec,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.numbers),
                    labelText: '최대 인원',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const SizedBox(
                  width: 30,
                ),
                const Text(
                  '태그 선택',
                ),
                const SizedBox(
                  height: 10,
                ),
                FutureBuilder(
                    future: tagList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var tags = snapshot.data as List;
                        selections =
                            List<bool>.generate(tags.length, (_) => false);
                        return Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ToggleButtons(
                                // 왜 fillcolor 안되냐고 씨발 진짜 ㅁㅊㄴㅁㅇ허 ㅁㄴ애랴ㅓㄴㅁ에
                                renderBorder: false,
                                fillColor: Colors.red,
                                onPressed: (index) {
                                  selectedTag = tags[index];
                                  setState(() {
                                    for (int i = 0; i < tags.length; i++) {
                                      selections[i] = (i == index);
                                    }
                                  });
                                  print(selections);
                                },
                                isSelected: selections,
                                children: List<Widget>.generate(
                                    tags.length,
                                    (index) => Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: selections[index]
                                                  ? Colors.red
                                                  : Colors.white,
                                              border: Border.all(width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            child: Text(tags[index]),
                                          ),
                                        ))),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
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
                OutlinedButton(
                    onPressed: () async {
                      var postBody = <String, dynamic>{
                        'groupName': nameTec.text,
                        'oneLineInfo': oneLineTec.text,
                        'groupDescription': bodyTec.text,
                        'maxMember': numTec.text,
                        'isPublic': isPublic,
                        'isAnonymous': isAnonymous,
                        'categoryLabel': selectedTag,
                      };
                      var url = Uri.http(baseUri, '/group/make');
                      var response = await http.post(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'authorization': 'Bearer $jwtToken'
                        },
                        body: jsonEncode(postBody),
                      );
                      if (response.statusCode == 200) {
                        print('groupaddsuccess');
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/bar', (route) => false);
                      } else {
                        print('fail ${response.statusCode}');
                      }
                    },
                    child: const Text('생성')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
