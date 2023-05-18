import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림함'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ListView.builder(
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(border: Border.all(width: 1)),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.message,
                    size: 45,
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('제목'),
                        Text('내용'),
                        Text('시간'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
