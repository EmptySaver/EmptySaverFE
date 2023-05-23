// import 'package:emptysaver_fe/fcm_setting.dart';
import 'package:emptysaver_fe/screen/bar_screen.dart';
import 'package:emptysaver_fe/screen/friend_group_screen_legacy.dart';
import 'package:emptysaver_fe/screen/info_new_screen.dart';
import 'package:emptysaver_fe/screen/login_screen_new.dart';
import 'package:emptysaver_fe/screen/notifications_screen.dart';
import 'package:emptysaver_fe/screen/timetable_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final tokensProvider = StateNotifierProvider((ref) => TokenStateNotifier(ref));

class TokenStateNotifier extends StateNotifier<List<String?>> {
  TokenStateNotifier(this.ref) : super([]);

  final Ref ref;

  void addToken(String? token) {
    state = [...state, token];
  }

  void removeToken(String? token) {
    state = state.where((e) => e != token).toList();
  }
}

//firebase code
Future reqIOSPermission(FirebaseMessaging fbMsg) async {
  NotificationSettings settings = await fbMsg.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

/// Firebase Background Messaging 핸들러

Future<void> fbMsgBackgroundHandler(RemoteMessage message) async {
  print("fcm!! data:${message.data}");
  print("[FCM - Background] MESSAGE : ${message.messageId}");
  //뭐 할게없네용 여기선..
}

/// Firebase Foreground Messaging 핸들러
Future<void> fbMsgForegroundHandler(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    AndroidNotificationChannel? channel) async {
  print("fcm!! total:${message.toString()}");
  print('[FCM - Foreground] MESSAGE : ${message.data}');
  print('[FCM - Foreground] MESSAGE title : ${message.notification?.title}');
  print('[FCM - Foreground] MESSAGE body : ${message.notification?.body}');
  print('[FCM - Foreground] MESSAGE id? : ${message.senderId}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
    flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              badgeNumber: 1,
              subtitle: 'the subtitle',
              sound: 'slow_spring_board.aiff',
            )));
    // flutterLocalNotificationsPlugin.initialize();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // 여기서 핸들링!
        print('onDidReceiveNotificationResponse - payload: ${details.payload}');

        String value = message.data["route"];
        print("route Value : $value");
        //이런식으로 메세지 data에 값을 넣어서 (Map<string,string>) route값을 백에서 보내겠슴다
        //그러면 값을 보고 뭔가 부차적인(*그룹id같은)값이 더 필요한 경우 공유해주시면 dataMap에 id로 추가해서 넣어주겠슴다
        //근데 여기서 큰 문제가 하나 있는데, 로그인,회원가입,비번초기화 페이지 제외하고는 로그인한 상태로 넘어가면 안되는디
        // 넘어가집니다
        // 그상태로 back갈기면 로그인페이지로 돌아가긴함다.
        Get.to(const InfoScreenNew());
        // Navigator.pushNamed(context, routeName)
      },
    );
  }
}

/// FCM 메시지 클릭 이벤트 정의
// Future<void> setupInteractedMessage(FirebaseMessaging fbMsg) async {
//   print("called click handler");
//   RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
//   // 종료상태에서 클릭한 푸시 알림 메세지 핸들링
//   if (initialMessage != null) clickMessageEvent(initialMessage);
//   // 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
//   FirebaseMessaging.onMessageOpenedApp.listen(clickMessageEvent);
// }

void clickMessageEvent(RemoteMessage message) {
  print(' In ClickMessageEvent: ${message.data}');
  print('message : ${message.notification!.title}');
  Get.toNamed('/noti');
}

void _handleMessage(RemoteMessage message) async {
  // final loggedIn = authManager.isLoggedIn;
  // if (loggedIn == false) {
  //   print('# [Auth] Not logged in, go to home');
  //   Get.offAllNamed('/home');
  //   return;
  // }

  // if (message.data.containsKey('페이지 이동 키값')) {
  //   await Get.toNamed('/이동페이지');
  //   return;
  // }
  String value = message.data["route"];
  print('백그라운드 클릭');
  print("route Value : $value");
  //이런식으로 메세지 data에 값을 넣어서 (Map<string,string>) route값을 백에서 보내겠슴다
  //그러면 값을 보고 뭔가 부차적인(*그룹id같은)값이 더 필요한 경우 공유해주시면 dataMap에 id로 추가해서 넣어주겠슴다
  //근데 여기서 큰 문제가 하나 있는데, 로그인,회원가입,비번초기화 페이지 제외하고는 로그인한 상태로 넘어가면 안되는디
  // 넘어가집니다
  // 그상태로 back갈기면 로그인페이지로 돌아가긴함다.
  Get.to(const NotificationsScreen());
}

void main() async {
  // await initializeDateFormatting('fr_FR', null)
  //     .then((_) => runApp(const MyApp()));
  /* WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // notification 설정
  String? firebaseToken = await fcmSetting(); 
  runApp(ProviderScope(child: MyApp(firebaseToken: firebaseToken))); */
  WidgetsFlutterBinding.ensureInitialized(); // 바인딩
  await Firebase.initializeApp();
  FirebaseMessaging fbMsg = FirebaseMessaging.instance;

  String? fcmToken =
      await fbMsg.getToken(vapidKey: "BGRA_GV..........keyvalue");
  //TODO : 서버에 해당 토큰을 저장하는 로직 구현
  print("Token: $fcmToken");
  //FCM 토큰은 사용자가 앱을 삭제, 재설치 및 데이터제거를 하게되면 기존의 토큰은 효력이 없고 새로운 토큰이 발금된다.
  fbMsg.onTokenRefresh.listen((nToken) {
    //TODO : 서버에 해당 토큰을 저장하는 로직 구현
  });
  runApp(ProviderScope(child: MyApp(firebaseToken: fcmToken)));

  // 플랫폼 확인후 권한요청 및 Flutter Local Notification Plugin 설정
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel? androidNotificationChannel;
  if (Platform.isIOS) {
    await reqIOSPermission(fbMsg);
  } else if (Platform.isAndroid) {
    //Android 8 (API 26) 이상부터는 채널설정이 필수.
    androidNotificationChannel = const AndroidNotificationChannel(
      'important_channel', // id
      'Important_Notifications', // name
      description: '중요도가 높은 알림을 위한 채널.',
      // description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }
  //Background Handling 백그라운드 메세지 핸들링 (메시지가 온 시점에 핸들러가 불림)
  FirebaseMessaging.onBackgroundMessage(fbMsgBackgroundHandler);
  //Foreground Handling 포어그라운드 메세지 핸들링 (메세지가 온 시점에 핸들러가 불린다.)
  FirebaseMessaging.onMessage.listen((message) {
    fbMsgForegroundHandler(
        message, flutterLocalNotificationsPlugin, androidNotificationChannel);
  });

  //백그라운드로 메세지 넘어오면 여기로 들어옴
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    _handleMessage(msg);
  });
  //앱종료상태에서 넘어오면 이렇게 옴
  RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  //Message Click Event Implement
  // await setupInteractedMessage(fbMsg);
}

class MyApp extends ConsumerWidget {
  String? firebaseToken;
  MyApp({
    super.key,
    required this.firebaseToken,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        firebaseToken: firebaseToken,
      ),
      routes: {
        '/bar': (context) => const BarScreen(),
        '/timetable': (context) => TimeTableScreen(),
        '/fg': (context) => const FriendGroupScreenOld(),
        '/noti': (context) => const NotificationsScreen(),
        '/info': (context) => const InfoScreenNew(),
      },
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            toolbarHeight: 50,
            centerTitle: true,
            backgroundColor: Colors.grey,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black))),
    );
  }
}
