import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GroupFinderScreen extends StatelessWidget {
  const GroupFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.5),
            ),
            height: 100,
            child: const Text('그룹'),
          ),
        ),
      ),
    );
  }
}
