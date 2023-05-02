import 'package:flutter/material.dart';

class MypageScreen extends StatelessWidget {
  const MypageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.5,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.person,
                      size: 100,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
