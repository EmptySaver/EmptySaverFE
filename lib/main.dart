// import 'package:emptysaver_fe/fcm_setting.dart';

import 'package:emptysaver_fe/element/controller.dart';
import 'package:emptysaver_fe/firebase_options.dart';
import 'package:emptysaver_fe/screen/bar_screen.dart';
import 'package:emptysaver_fe/screen/each_post_screen.dart';
import 'package:emptysaver_fe/screen/friend_check_screen_new.dart';
import 'package:emptysaver_fe/screen/friend_group_screen_new.dart';
import 'package:emptysaver_fe/screen/group_detail_screen.dart';
import 'package:emptysaver_fe/screen/group_finder_detail_screen.dart';
import 'package:emptysaver_fe/screen/info_new_screen.dart';
import 'package:emptysaver_fe/screen/login_screen_new_style.dart';
import 'package:emptysaver_fe/screen/invitation_screen_new.dart';
//import 'package:emptysaver_fe/screen/login_screen_new.dart';
import 'package:emptysaver_fe/screen/notifications_screen.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

final tokensProvider = StateNotifierProvider((ref) => TokenStateNotifier(ref));
var logger = Logger();
var storage = const FlutterSecureStorage();
dynamic userInfo;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
FirebaseMessaging fbMsg = FirebaseMessaging.instance;
bool isFlutterLocalNotificationsInitialized = false; // 셋팅여부 판단 flag

void main() async {
  // await initializeDateFormatting('fr_FR', null)
  //     .then((_) => runApp(const MyApp()));
  WidgetsFlutterBinding.ensureInitialized(); // 바인딩
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  String? fcmToken = await getToken();
  Get.put(AutoLoginController());

  runApp(ProviderScope(child: MyApp(firebaseToken: fcmToken)));

  //FCM 토큰은 사용자가 앱을 삭제, 재설치 및 데이터제거를 하게되면 기존의 토큰은 효력이 없고 새로운 토큰이 발금된다.
  // fbMsg.onTokenRefresh.listen((nToken) {
  //   //TODO : 서버에 해당 토큰을 저장하는 로직 구현
  // });
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  // 플랫폼 확인후 권한요청 및 채널 설정

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  // iOS foreground notification 권한
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // IOS background 권한 체킹 , 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // 셋팅flag 설정
  isFlutterLocalNotificationsInitialized = true;
}

Future<String?> getToken() async {
  // ios
  String? token;
  if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
    token = await FirebaseMessaging.instance.getAPNSToken();
  }
  // aos
  else {
    token = await FirebaseMessaging.instance.getToken();
  }
  logger.i("fcmToken : $token");
  return token;
}

/// fcm 백그라운드 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupFlutterNotifications(); // 셋팅 메소드
  // showFlutterNotification(message); // 로컬노티
}

/// 로컬 알림 화면에 띄우는 메서드
void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    // 웹이 아니면서 안드로이드이고, 알림이 있는경우
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          badgeNumber: 1,
          subtitle: 'the subtitle',
          sound: 'slow_spring_board.aiff',
        ),
      ),
    );
  }
}

void _handleMessage(RemoteMessage message, FlutterSecureStorage storage, dynamic userInfo) async {
  userInfo = await storage.read(key: 'login');
  if (userInfo != null) {
    // var decodedUserInfo = jsonDecode(userInfo);
    // var url = Uri.parse('http://43.201.208.100:8080/auth/login');
    // var response = await http.post(url,
    //     headers: {
    //       'Content-Type': 'application/json; charset=UTF-8',
    //     },
    //     body: jsonEncode({
    //       'email': decodedUserInfo['email'],
    //       'password': decodedUserInfo['password'],
    //       'fcmToken': decodedUserInfo['fcmToken'],
    //     }));
    // if (response.statusCode == 200) {
    //   print('푸시 눌러 자동로그인성공, jwt토큰발급');
    //   var jwtToken = await storage.read(key: 'jwtToken');
    //   if (jwtToken == null) {
    //     await storage.write(key: 'jwtToken', value: response.body);
    //     jwtToken = await storage.read(key: 'jwtToken');
    //     Get.find<AutoLoginController>().addToken(jwtToken!);
    //   } else {
    //     await storage.delete(key: 'jwtToken');
    //     await storage.write(key: 'jwtToken', value: response.body);
    //     jwtToken = await storage.read(key: 'jwtToken');
    //     Get.find<AutoLoginController>().updateToken(jwtToken!);
    //   }
    //   print('Getjwt : ${Get.find<AutoLoginController>().state}');
    String routeValue = message.data["routeValue"];
    String? idType = message.data["idType"];
    String? idType2 = message.data["idType2"] ?? 'x';
    int? idValue = int.parse(message.data['idValue']);
    int? idValue2 = message.data['idValue2'] != null ? int.parse(message.data['idValue2']) : -1;
    routeSwitching(routeValue, idType: idType, idType2: idType2, idValue: idValue, idValue2: idValue2);
    // }
  }
  print('백그라운드 클릭');
  // print("route Value : $route");
  // Get.to(const NotificationsScreen());
}

void terminatedHandler() async {
  RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage, storage, userInfo);
  }
}

void routeSwitching(String? routeValue, {String? idType, String? idType2, int? idValue, int? idValue2}) {
  switch (routeValue) {
    case 'notification':
      switch (idType) {
        case 'x': // 공지사항 등록시 알림인데 따로 이동해야하나? postId, groupId 필요
          Get.to(() => GroupDetailScreen(
                // groupId 필요
                groupId: idValue,
              ));
          break;
        case 'Schedule':
          print('스케줄아이디 : $idValue');
          print('그룹id : $idValue2');
          Get.to(() => GroupDetailScreen(
                // groupId 필요
                groupId: idValue2,
              ));
          break;
        case 'friend':
          Get.to(() => const FriendCheckScreen());
          break;
        case 'group':
          Get.to(() => const InvitationScreen());
      }
      break;
    case 'groupDetail':
      Get.to(() => GroupFinderDetailScreen(
            id: idValue,
          ));
    case 'post':
      Get.to(() => EachPostScreen(
            groupId: idValue,
            postId: idValue2,
          ));
      break;
    case 'friend':
      Get.to(() => FriendGroupScreen(
            isGroup: false,
          ));
    case 'group':
      Get.to(() => GroupDetailScreen(
            groupId: idValue,
          ));
  }
}

class MyApp extends ConsumerStatefulWidget {
  String? firebaseToken;
  MyApp({
    super.key,
    required this.firebaseToken,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // foreground 수신처리(메시지 온 시점에 실행)
    FirebaseMessaging.onMessage.listen(
      (message) async {
        showFlutterNotification(message);
        await flutterLocalNotificationsPlugin.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(),
          ),
          // foreground 알림 클릭시 실행
          onDidReceiveNotificationResponse: (NotificationResponse details) async {
            print('onDidReceiveNotificationResponse - payload: ${details.payload}');
            userInfo = await storage.read(key: 'login');
            if (userInfo != null) {
              String? routeValue = message.data["routeValue"];
              String? idType = message.data["idType"];
              String? idType2 = message.data["idType2"] ?? 'x';
              int? idValue = int.parse(message.data['idValue']);
              int? idValue2 = message.data['idValue2'] != null ? int.parse(message.data['idValue2']) : -1;
              routeSwitching(routeValue, idType: idType, idType2: idType2, idValue: idValue, idValue2: idValue2);
            } else {
              print('포그라운드에서 알림 눌렀지만 유저정보 없음');
              // Get.toNamed('/');
              return;
            }
            // Navigator.pushNamed(context, routeName)
          },
        );
      },
    );
    // background 수신처리(메시지 온 시점에 실행)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // 백그라운드에서 알림 클릭시 처리
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message, storage, userInfo);
    });
    // 앱종료상태(화면꺼짐포함)에서 알림 클릭시 처리
    terminatedHandler();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return GetMaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      locale: const Locale('ko'),
      debugShowCheckedModeBanner: false,
      home: NewLoginScreen(
        firebaseToken: widget.firebaseToken,
      ),
      routes: {
        '/bar': (context) => const BarScreen(),
        '/timetable': (context) => TimeTableScreen(),
        '/fg': (context) => FriendGroupScreen(),
        '/noti': (context) => const NotificationsScreen(),
        '/info': (context) => const InfoScreenNew(),
      },
      theme: ThemeData(
          // scaffoldBackgroundColor: const Color(0xfff0f0f0),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
                systemNavigationBarDividerColor: Colors.black12),
            toolbarHeight: 40,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueGrey,
            elevation: 0,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              side: const BorderSide(color: Colors.blue, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
          dividerTheme: DividerThemeData(color: Colors.blueGrey.shade100),
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: Colors.blueGrey.shade900),
          )),
    );
  }
}
