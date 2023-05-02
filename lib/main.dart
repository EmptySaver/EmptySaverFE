import 'package:emptysaver_fe/fcm_setting.dart';
import 'package:emptysaver_fe/screen/bar_screen.dart';
import 'package:emptysaver_fe/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // await initializeDateFormatting('fr_FR', null)
  //     .then((_) => runApp(const MyApp()));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // notification 설정
  String? firebaseToken = await fcmSetting();
  runApp(MyApp(firebaseToken: firebaseToken));
}

class MyApp extends StatelessWidget {
  String? firebaseToken;
  MyApp({
    super.key,
    required this.firebaseToken,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: LoginScreen(
        firebaseToken: firebaseToken,
      ),
      routes: {
        '/bar': (context) => const BarScreen(),
      },
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            toolbarHeight: 50,
            centerTitle: true,
            backgroundColor: Colors.grey,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Colors.grey,
              ),
            ),
          )),
    );
  }
}
