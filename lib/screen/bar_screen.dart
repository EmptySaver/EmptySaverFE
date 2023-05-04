import 'package:emptysaver_fe/screen/friend_group_screen.dart';
import 'package:emptysaver_fe/screen/group_finder_screen.dart';
import 'package:emptysaver_fe/screen/mypage_screen.dart';
import 'package:emptysaver_fe/screen/notifications_screen.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:emptysaver_fe/main.dart';

class BarScreen extends ConsumerStatefulWidget {
  // String? firebaseToken;
  const BarScreen({
    super.key,
  });

  @override
  ConsumerState<BarScreen> createState() => _BarScreenState();
}

class _BarScreenState extends ConsumerState<BarScreen> {
  int selectedIndex = 0;
  var bodyWidgets = [
    TimeTableScreen(),
    const FriendGroupScreen(),
    const GroupFinderScreen(),
    const Text('정보'),
  ];
  @override
  Widget build(BuildContext context) {
    var jwtToken = ref.read(tokensProvider.notifier).state;
    print('barproviderjwt : $jwtToken');
    http.post(
      Uri.parse('http://43.201.208.100:8080/notification/send'),
      // body: jsonEncode(<String, dynamic>{
      //   'userId': '1',
      //   'title': 'test',
      //   'body': '테스트중',
      // }),
      headers: <String, String>{
        'authorization': 'Bearer',
        'Content-Type': 'application/json',
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('공강구조대!'),
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
                    builder: (context) => const MypageScreen(),
                  ));
            },
            icon: const Icon(Icons.person),
          )
        ],
        leading: IconButton(
          onPressed: () async {
            var url = Uri.parse('http://43.201.208.100:8080/afterAuth/logout');
            var response = await http.post(
              url,
              headers: <String, String>{
                'Content-Type': 'application/json',
                'authorization': 'Bearer ${jwtToken[0]}'
              },
            );
            if (response.statusCode == 200) {
              ref.read(tokensProvider.notifier).removeToken(jwtToken[0]);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } else {
              print(response.statusCode);
              print((response.body));
            }
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: bodyWidgets.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
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
              label: '친구/그룹',
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
