import 'package:flutter/material.dart';

class FriendGroupScreen extends StatelessWidget {
  const FriendGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('rebuild');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '친구',
                  ),
                  OutlinedButton(onPressed: () {}, child: const Text('추가'))
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              height: 250,
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Container(
                        height: 40,
                        color: Colors.amber,
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                    itemCount: 10),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('모임'),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('생성'),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(width: 1),
              ),
              clipBehavior: Clip.hardEdge,
              height: 250,
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Container(
                        height: 40,
                        color: Colors.green,
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: 5,
                        ),
                    itemCount: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
