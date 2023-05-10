import 'package:flutter/material.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: SizedBox(
            width: 350,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  '그룹 타이틀',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('공지사항'),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 150,
                  width: 350,
                  decoration: const BoxDecoration(color: Colors.amber),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('일정 목록'),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('추가'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 150,
                  width: 350,
                  decoration: const BoxDecoration(color: Colors.green),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('구성원 목록'),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('초대'),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 150,
                  width: 350,
                  decoration: const BoxDecoration(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
