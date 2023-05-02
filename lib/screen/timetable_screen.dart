import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class TimeTableScreen extends StatelessWidget {
  TimeTableScreen({super.key});
  final ScrollController controller = ScrollController();
  final ScrollController controller2 = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            initialPage: 1,
            height: 700,
            viewportFraction: 0.9,
          ),
          itemCount: 3,
          itemBuilder: (context, index, realIndex) {
            print(DateFormat.yMMMMEEEEd()
                .format(DateTime.now().add(const Duration(hours: 9))));
            return SingleChildScrollView(
              padding: const EdgeInsets.all(1),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Row(children: [
                  Column(children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                    ),
                    for (int i = 1; i < 17; i++) TimeHeaderBox(timeText: i + 7),
                  ]),
                  Column(
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < 4; i++)
                            DefaultHeaderBox(
                              nowDate: '${DateFormat('E', 'ko').format(
                                DateTime.now().add(
                                  Duration(
                                    days: (i - 4 + index * 4),
                                    hours: 9,
                                  ),
                                ),
                              )} ${DateFormat('d').format(DateTime.now().add(Duration(days: (i - 4 + index * 4), hours: 9)))}',
                            )
                        ],
                      ),
                      Row(
                        children: [
                          for (int i = 0; i < 4; i++)
                            Column(
                              children: [
                                for (int j = 0; j < 32; j++)
                                  Container(
                                    width: 83,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        border: Border(
                                      left: const BorderSide(
                                          color: Colors.blueGrey, width: 0.2),
                                      right: const BorderSide(
                                          color: Colors.blueGrey, width: 0.2),
                                      bottom: (j % 2 == 1)
                                          ? const BorderSide(
                                              color: Colors.blueGrey,
                                              width: 0.2)
                                          : BorderSide.none,
                                    )),
                                  )
                              ],
                            ),
                        ],
                      )
                    ],
                  )
                ]),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Positioned(
                  child: FloatingActionButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Positioned(
                    child: FloatingActionButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add),
                ))
              ],
            ),
          ),
        )
      ],
    );
    // int deviceHeight = MediaQuery.of(context).size.height.toInt();
    // return Scrollbar(
    //   controller: controller2,
    //   // thumbVisibility: true,
    //   child: SingleChildScrollView(
    //     controller: controller2,
    //     scrollDirection: Axis.horizontal,
    //     child: Scrollbar(
    //       controller: controller,
    //       // thumbVisibility: true,
    //       child: SingleChildScrollView(
    //         controller: controller,
    //         child: Row(
    //           children: [
    //             for (int i = 1; i < 10; i++)
    //               Column(
    //                 children: [
    //                   for (int j = 1; j < 100; j++) const DefaultBox(),
    //                 ],
    //               ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class TimeHeaderBox extends StatelessWidget {
  late int timeText;
  TimeHeaderBox({
    super.key,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 0.2),
      ),
      child: Text(
        '$timeText',
        textAlign: TextAlign.end,
      ),
    );
  }
}

class DefaultBox extends StatelessWidget {
  const DefaultBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 83,
      height: 40,
      decoration:
          BoxDecoration(border: Border.all(color: Colors.blueGrey, width: 0.2)),
    );
  }
}

class DefaultHeaderBox extends StatelessWidget {
  late String nowDate;
  DefaultHeaderBox({
    super.key,
    required this.nowDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 83,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 0.2),
      ),
      child: Center(child: Text(nowDate)),
    );
  }
}
