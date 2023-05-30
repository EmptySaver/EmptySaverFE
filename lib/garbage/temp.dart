// // import 'package:emptysaver_fe/fcm_setting.dart';
// import 'dart:convert';

// import 'package:emptysaver_fe/element/controller.dart';
// import 'package:emptysaver_fe/firebase_options.dart';
// import 'package:emptysaver_fe/screen/bar_screen.dart';
// import 'package:emptysaver_fe/screen/friend_group_screen_new.dart';
// import 'package:emptysaver_fe/screen/info_new_screen.dart';
// import 'package:emptysaver_fe/screen/login_screen_new.dart';
// import 'package:emptysaver_fe/screen/notifications_screen.dart';
// import 'package:emptysaver_fe/screen/timetable_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:http/http.dart' as http;

// final tokensProvider = StateNotifierProvider((ref) => TokenStateNotifier(ref));

// //firebase code
// Future reqIOSPermission(FirebaseMessaging fbMsg) async {
//   NotificationSettings settings = await fbMsg.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }

// /// Firebase Background Messaging 핸들러

// Future<void> fbMsgBackgroundHandler(RemoteMessage message) async {
//   print("[FCM - Background] MESSAGE : ${message.messageId}");
//   flutterLocalNotificationsPlugin.show(
//       message.hashCode,
//       message.notification?.title,
//       message.notification?.body,
//       NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel!.id,
//             channel!.name,
//             channelDescription: channel!.description,
//             icon: '@mipmap/ic_launcher',
//           ),
//           iOS: const DarwinNotificationDetails(
//             badgeNumber: 1,
//             subtitle: 'the subtitle',
//             sound: 'slow_spring_board.aiff',
//           )));
// }

// /// Firebase Foreground Messaging 핸들러
// Future<void> fbMsgForegroundHandler(
//     RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel? channel, FlutterSecureStorage storage, dynamic userInfo) async {
//   print("fcm!! total:${message.toString()}");
//   print('[FCM - Foreground] MESSAGE : ${message.data}');
//   print('[FCM - Foreground] MESSAGE title : ${message.notification?.title}');
//   print('[FCM - Foreground] MESSAGE body : ${message.notification?.body}');
//   print('[FCM - Foreground] MESSAGE id? : ${message.senderId}');
//   if (message.notification != null) {
//     print('Message also contained a notification: ${message.notification}');
//     flutterLocalNotificationsPlugin.show(
//         message.hashCode,
//         message.notification?.title,
//         message.notification?.body,
//         NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel!.id,
//               channel.name,
//               channelDescription: channel.description,
//               icon: '@mipmap/ic_launcher',
//             ),
//             iOS: const DarwinNotificationDetails(
//               badgeNumber: 1,
//               subtitle: 'the subtitle',
//               sound: 'slow_spring_board.aiff',
//             )));
//     // flutterLocalNotificationsPlugin.initialize();
//     await flutterLocalNotificationsPlugin.initialize(
//       const InitializationSettings(
//         android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//         iOS: DarwinInitializationSettings(),
//       ),
//       onDidReceiveNotificationResponse: (NotificationResponse details) async {
//         // 여기서 핸들링!
//         print('onDidReceiveNotificationResponse - payload: ${details.payload}');
//         // String route = message.data["route"];
//         userInfo = await storage.read(key: 'login');
//         if (userInfo != null) {
//           Get.toNamed('/fg');
//         } else {
//           print('포그라운드에서 알림 눌렀지만 유저정보 없음');
//           Get.toNamed('/');
//           return;
//         }
//         // Navigator.pushNamed(context, routeName)
//       },
//     );
//   }
// }

// /// FCM 메시지 클릭 이벤트 정의
// // Future<void> setupInteractedMessage(FirebaseMessaging fbMsg) async {
// //   print("called click handler");
// //   RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
// //   // 종료상태에서 클릭한 푸시 알림 메세지 핸들링
// //   if (initialMessage != null) clickMessageEvent(initialMessage);
// //   // 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
// //   FirebaseMessaging.onMessageOpenedApp.listen(clickMessageEvent);
// // }

// // void clickMessageEvent(RemoteMessage message) {
// //   print(' In ClickMessageEvent: ${message.data}');
// //   print('message : ${message.notification!.title}');
// //   Get.toNamed('/noti');
// // }

// void _handleMessage(RemoteMessage message, FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, AndroidNotificationChannel? channel, FlutterSecureStorage storage, dynamic userInfo) async {
//   Get.put(AutoLoginController());
//   // String route = message.data["route"];
//   userInfo = await storage.read(key: 'login');
//   // final loggedIn = authManager.isLoggedIn;
//   // if (loggedIn == false) {
//   //   print('# [Auth] Not logged in, go to home');
//   //   Get.offAllNamed('/home');
//   //   return;
//   // }

//   // if (message.data.containsKey('페이지 이동 키값')) {
//   //   await Get.toNamed('/이동페이지');
//   //   return;
//   // }

// // 내 코드
//   if (userInfo != null) {
//     var decodedUserInfo = jsonDecode(userInfo);
//     var url = Uri.parse('http://43.201.208.100:8080/auth/login');
//     var response = await http.post(url,
//         headers: {
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode({
//           'email': decodedUserInfo['email'],
//           'password': decodedUserInfo['password'],
//           'fcmToken': decodedUserInfo['fcmToken'],
//         }));
//     if (response.statusCode == 200) {
//       print('푸시 눌러 자동로그인성공, jwt토큰발급');
//       var jwtToken = await storage.read(key: 'jwtToken');
//       if (jwtToken == null) {
//       } else {
//         await storage.write(key: 'jwtToken', value: response.body);
//         jwtToken = await storage.read(key: 'jwtToken');
//         Get.find<AutoLoginController>().addToken(jwtToken!);
//       }
//       print('Getjwt : ${Get.find<AutoLoginController>().state}');
//       Get.toNamed('/fg');
//     }
//   }

//   print('백그라운드 클릭');
//   // print("route Value : $route");
//   // Get.to(const NotificationsScreen());
// }

// //Flutter Local Notification Plugin, AndroidNotificationChannel 초기화
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// AndroidNotificationChannel? channel;

// void main() async {
//   // await initializeDateFormatting('fr_FR', null)
//   //     .then((_) => runApp(const MyApp()));
//   WidgetsFlutterBinding.ensureInitialized(); // 바인딩
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   FirebaseMessaging fbMsg = FirebaseMessaging.instance;
//   //test
//   const storage = FlutterSecureStorage();
//   dynamic userInfo;

//   String? fcmToken = await fbMsg.getToken(vapidKey: "BGRA_GV..........keyvalue");
//   //TODO : 서버에 해당 토큰을 저장하는 로직 구현
//   print("Token: $fcmToken");
//   //FCM 토큰은 사용자가 앱을 삭제, 재설치 및 데이터제거를 하게되면 기존의 토큰은 효력이 없고 새로운 토큰이 발금된다.
//   fbMsg.onTokenRefresh.listen((nToken) {
//     //TODO : 서버에 해당 토큰을 저장하는 로직 구현
//   });

//   // 플랫폼 확인후 권한요청 및 채널 설정
//   if (Platform.isIOS) {
//     await reqIOSPermission(fbMsg);
//   } else if (Platform.isAndroid) {
//     //Android 8 (API 26) 이상부터는 채널설정이 필수.
//     channel = const AndroidNotificationChannel(
//       'important_channel', // id
//       'Important_Notifications', // name
//       description: '중요도가 높은 알림을 위한 채널.',
//       // description
//       importance: Importance.high,
//     );

//     await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel!);
//   }
//   //Background Handling 백그라운드 메세지 핸들링 (메시지가 온 시점에 핸들러가 불림)
//   FirebaseMessaging.onBackgroundMessage(fbMsgBackgroundHandler);
//   //Foreground Handling 포어그라운드 메세지 핸들링 (메세지가 온 시점에 핸들러가 불린다.)
//   FirebaseMessaging.onMessage.listen((message) {
//     fbMsgForegroundHandler(message, flutterLocalNotificationsPlugin, channel, storage, userInfo);
//   });

//   //백그라운드에서 알림 클릭시 처리
//   FirebaseMessaging.onMessageOpenedApp.listen((msg) {
//     _handleMessage(msg, flutterLocalNotificationsPlugin, channel, storage, userInfo);
//   });
//   //앱종료상태에서 알림 클릭시 처리
//   RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
//   if (initialMessage != null) {
//     _handleMessage(initialMessage, flutterLocalNotificationsPlugin, channel, storage, userInfo);
//   }
//   //Message Click Event Implement
//   // await setupInteractedMessage(fbMsg);

//   runApp(ProviderScope(child: MyApp(firebaseToken: fcmToken)));
// }

// class MyApp extends ConsumerWidget {
//   String? firebaseToken;
//   MyApp({
//     super.key,
//     required this.firebaseToken,
//   });
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return GetMaterialApp(
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('ko', 'KR'),
//       ],
//       locale: const Locale('ko'),
//       debugShowCheckedModeBanner: false,
//       home: NewLoginScreen(
//         firebaseToken: firebaseToken,
//       ),
//       routes: {
//         '/bar': (context) => const BarScreen(),
//         '/timetable': (context) => TimeTableScreen(),
//         '/fg': (context) => const FriendGroupScreen(),
//         '/noti': (context) => const NotificationsScreen(),
//         '/info': (context) => const InfoScreenNew(),
//       },
//       theme: ThemeData(
//           appBarTheme: const AppBarTheme(
//             toolbarHeight: 50,
//             centerTitle: true,
//             backgroundColor: Colors.grey,
//           ),
//           outlinedButtonTheme: OutlinedButtonThemeData(
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.black,
//               side: const BorderSide(
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.black))),
//     );
//   }
// }
