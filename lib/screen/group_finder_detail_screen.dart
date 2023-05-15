import 'package:flutter/material.dart';

class GroupFinderDetailScreen extends StatefulWidget {
  const GroupFinderDetailScreen({super.key});

  @override
  State<GroupFinderDetailScreen> createState() =>
      _GroupFinderDetailScreenState();
}

class _GroupFinderDetailScreenState extends State<GroupFinderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Text('그룹가입상세페이지'),
    );
  }
}
