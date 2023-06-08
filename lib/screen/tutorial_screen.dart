import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialScreen extends StatefulWidget{
  TutorialScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TutorialScreen();

}

class _TutorialScreen extends State<TutorialScreen>{
  //int _counter = 0;
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  Widget build(BuildContext context) {
    //ToDo: 이미지 개수에 맞춰서 설명 달기
    final List<String> descriptions = ["일정 추가와 그룹 생성도 간편하게!"
      , "자신의 시간표를 구성해 보세요."
      ,"영화도 시간표에 빠르게 추가!"
      ,"그룹과 친구 관리도 간단하게"
      , "교내의 그룹도 빠르게 검색!"
      , "취업과 비교과 정보도 확인해보세요."
    ];

    final pages = List.generate(
        6,
            (index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                //color: Colors.grey.shade300,
                /*
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/tuto$index.png')
                        )*/
              ),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Container(
                height: 280,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/tutor$index.png',fit: BoxFit.fill,),
                      //width: 250, height: 150
                    ),
                    SizedBox(height: 20,),
                    Text(descriptions[index]
                      ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.black)
                    )
                  ],
                )
                /*Text(
                  "Page $index",
                  style: TextStyle(color: Colors.indigo),
                )*/
              ),
           ),
        );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
              padding: const EdgeInsets.only(top: 120, bottom: 12),
              child: const Text(
                  '공강 구조대 서비스 안내',
                  style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold ,color: Colors.black),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: PageView.builder(
                  controller: controller,
                  // itemCount: pages.length,
                  itemBuilder: (_, index) {
                    return pages[index % pages.length];
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                /*child: Text(
                  'Worm',
                  style: TextStyle(color: Colors.black54),
                ),*/
              ),
              SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: const WormEffect(
                  activeDotColor: Colors.blue,
                  dotHeight: 16,
                  dotWidth: 16,
                  type: WormType.thinUnderground,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 12),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue,width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {Navigator.pop(context);},
                  child: const Text(
                    '바로 시작하기',
                    style: TextStyle(
                      //fontFamily: 'NimbusSanL',
                      fontSize: 15,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              //
              // Padding(
              //   padding: const EdgeInsets.only(top: 16, bottom: 8),
              //   child: Text(
              //     'Jumping Dot',
              //     style: TextStyle(color: Colors.black54),
              //   ),
              // ),
              // Container(
              //   child: SmoothPageIndicator(
              //     controller: controller,
              //     count: pages.length,
              //     effect: JumpingDotEffect(
              //       dotHeight: 16,
              //       dotWidth: 16,
              //       jumpScale: .7,
              //       verticalOffset: 15,
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 16, bottom: 12),
              //   child: Text(
              //     'Scrolling Dots',
              //     style: TextStyle(color: Colors.black54),
              //   ),
              // ),
              // SmoothPageIndicator(
              //     controller: controller,
              //     count: pages.length,
              //     effect: ScrollingDotsEffect(
              //       activeStrokeWidth: 2.6,
              //       activeDotScale: 1.3,
              //       maxVisibleDots: 5,
              //       radius: 8,
              //       spacing: 10,
              //       dotHeight: 12,
              //       dotWidth: 12,
              //     )),
              // Padding(
              //   padding: const EdgeInsets.only(top: 16, bottom: 16),
              //   child: Text(
              //     'Customizable Effect',
              //     style: TextStyle(color: Colors.black54),
              //   ),
              // ),
              // Container(
              //   // color: Colors.red.withOpacity(.4),
              //   child: SmoothPageIndicator(
              //     controller: controller,
              //     count: pages.length,
              //     effect: CustomizableEffect(
              //       activeDotDecoration: DotDecoration(
              //         width: 32,
              //         height: 12,
              //         color: Colors.indigo,
              //         rotationAngle: 180,
              //         verticalOffset: -10,
              //         borderRadius: BorderRadius.circular(24),
              //         // dotBorder: DotBorder(
              //         //   padding: 2,
              //         //   width: 2,
              //         //   color: Colors.indigo,
              //         // ),
              //       ),
              //       dotDecoration: DotDecoration(
              //         width: 24,
              //         height: 12,
              //         color: Colors.grey,
              //         // dotBorder: DotBorder(
              //         //   padding: 2,
              //         //   width: 2,
              //         //   color: Colors.grey,
              //         // ),
              //         // borderRadius: BorderRadius.only(
              //         //     topLeft: Radius.circular(2),
              //         //     topRight: Radius.circular(16),
              //         //     bottomLeft: Radius.circular(16),
              //         //     bottomRight: Radius.circular(2)),
              //         borderRadius: BorderRadius.circular(16),
              //         verticalOffset: 0,
              //       ),
              //       spacing: 6.0,
              //       // activeColorOverride: (i) => colors[i],
              //       inActiveColorOverride: (i) => colors[i],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}

final colors = const [
  Colors.red,
  Colors.green,
  Colors.greenAccent,
  Colors.amberAccent,
  Colors.blue,
  Colors.amber,
];
  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text(
            '뒤로가버렷',
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}*/