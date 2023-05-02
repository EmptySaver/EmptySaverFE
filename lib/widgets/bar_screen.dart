import 'package:emptysaver_fe/widgets/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BarScreen extends StatefulWidget {
  // String? firebaseToken;
  const BarScreen({
    super.key,
    // required this.firebaseToken,
  });

  @override
  State<BarScreen> createState() => _BarScreenState();
}

class _BarScreenState extends State<BarScreen> {
  int selectedIndex = 0;
  var bodyWidgets = [
    TimeTableScreen(),
    const Text('친구/그룹'),
    const Text('그룹 찾기'),
    const Text('정보'),
  ];
  @override
  Widget build(BuildContext context) {
    // print('barscreen : ${widget.firebaseToken}');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('공강구조대!'),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person))
        ],
        leading: IconButton(
          onPressed: () async {
            var url = Uri.parse('http://43.201.208.100:8080/afterAuth/logout');
            var response = await http.post(
              url,
              // headers: <String, String>{
              //   'Content-Type': 'application/json; charset=UTF-8'
              // },
            );
            if (response.statusCode == 200) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } else {
              print(response.statusCode);
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
