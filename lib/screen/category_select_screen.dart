import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/screen/add_group_screen_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:emptysaver_fe/element/factory_fromjson.dart';

class CategorySelectScreen extends ConsumerStatefulWidget {
  const CategorySelectScreen({super.key});

  @override
  ConsumerState<CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends ConsumerState<CategorySelectScreen> {
  var baseUri = '43.201.208.100:8080';
  var jwtToken = AutoLoginController.to.state[0];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 50,
              ),
              OutlinedButton(
                onPressed: () async {
                  var url = Uri.http(baseUri, '/category/getCategoryList');
                  var response = await http.get(url, headers: {'authorization': 'Bearer $jwtToken'});
                  print(jsonDecode(utf8.decode(response.bodyBytes)));
                  var parsedJson = jsonDecode(utf8.decode(response.bodyBytes));
                  Category category = Category.fromJson(parsedJson);
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Center(
                        child: Text('카테고리'),
                      ),
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: category.data!
                              .map((e) => TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddGroupScreen(
                                            type: e['type'],
                                            name: e['name'],
                                          ),
                                        ));
                                  },
                                  child: Text(e['name'])))
                              .toList(),
                        )
                      ],
                    ),
                  );
                },
                child: const Text('카테고리 고르기'),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Text('추천목록'),
                        const SizedBox(
                          height: 20,
                        ),
                        ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) => Container(
                                  height: 90,
                                  decoration: BoxDecoration(border: Border.all(width: 1)),
                                ),
                            separatorBuilder: (context, index) => const SizedBox(
                                  height: 5,
                                ),
                            itemCount: 6)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
