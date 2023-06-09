import 'dart:convert';

// import 'package:emptysaver_fe/screen/friend_group_screen_legacy.dart';
import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/screen/friend_group_screen_new.dart';
// import 'package:emptysaver_fe/screen/group_finder_screen_legacy.dart';
import 'package:emptysaver_fe/screen/group_finder_screen_new.dart';
import 'package:emptysaver_fe/screen/info_new_screen.dart';
import 'package:emptysaver_fe/screen/mypage_screen_new.dart';
import 'package:emptysaver_fe/screen/notifications_screen.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:emptysaver_fe/screen/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BarScreen extends StatefulWidget {
  int? routeIndex;
  // String? firebaseToken;
  BarScreen({super.key, this.routeIndex});

  @override
  State<BarScreen> createState() => _BarScreenState();
}

class _BarScreenState extends State<BarScreen> {
  static const String isTutorialRead = "tutorialRead";
  int selectedIndex = 0;
  var bodyWidgets = [
    TimeTableScreen(),
    FriendGroupScreen(),
    const GroupFinderScreen(),
    const InfoScreenNew(),
  ];
  var jwtToken = AutoLoginController.to.state[0];
  static const storage = FlutterSecureStorage();
  late dynamic userInfo;

  Future<void> logoutMethod(BuildContext context) async {
    {
      var url = Uri.parse('http://43.201.208.100:8080/afterAuth/logout');
      var response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json', 'authorization': 'Bearer $jwtToken'},
      );
      if (response.statusCode == 200) {
        await storage.delete(key: 'login');
        userInfo = await storage.read(key: 'login');
        if (userInfo == null) {
          print('유저정보 삭제됐음');
          Fluttertoast.showToast(msg: '로그아웃되었습니다');
          // ref.read(tokensProvider.notifier).removeToken(jwtToken);
          Get.find<AutoLoginController>().removeToken(jwtToken);
          print('Getjwt : ${Get.find<AutoLoginController>().state}');
          // print('riverpodjwt : ${ref.read(tokensProvider.notifier).state}');
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          print('유저정보 남아있음');
          return;
        }
      } else {
        print(utf8.decode(response.bodyBytes));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print('barinit');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tutorialActive();
    });
    selectedIndex = widget.routeIndex ?? 0;
  }

  tutorialActive() async {
    // await storage.delete(key: isTutorialRead);
    String? isRead = await storage.read(key: isTutorialRead);
    if (isRead != "true") {
      storage.write(key: isTutorialRead, value: "true"); //다시 실행 안되도록 값 저장
      Navigator.push(context, MaterialPageRoute(builder: (context) => TutorialScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ));
            },
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPageScreen(),
                  ));
            },
            icon: const Icon(Icons.person),
          )
        ],
        leading: IconButton(
          onPressed: () {
            logoutMethod(context);
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: WillPopScope(
          onWillPop: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('앱 종료'),
                content: const Text('앱을 종료하시겠습니까?'),
                actions: [
                  TextButton(
                    child: const Text('취소'),
                    onPressed: () {
                      Navigator.of(context).pop(false); // 앱 종료 취소
                    },
                  ),
                  TextButton(
                    child: const Text('확인'),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            );
            return false; // 앱 종료 막음
          },
          child: bodyWidgets.elementAt(selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
          elevation: 100,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.blueGrey,
          backgroundColor: Colors.white,
          currentIndex: selectedIndex,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          // fixedColor: Colors.grey,
          // backgroundColor: Colors.grey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_rounded),
              label: '그룹/친구',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_add),
              label: '그룹 찾기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: '정보',
            ),
          ]),
    );
  }
}
