import 'package:emptysaver_fe/fcm_setting.dart';
import 'package:emptysaver_fe/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

void main() async {
  // await initializeDateFormatting('fr_FR', null)
  //     .then((_) => runApp(const MyApp()));
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // notification 설정
  String? firebaseToken = await fcmSetting();
  runApp(ProviderScope(child: MyApp(firebaseToken: firebaseToken)));
}

class MyApp extends ConsumerWidget {
  String? firebaseToken;
  MyApp({
    super.key,
    required this.firebaseToken,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      // routes: {
      //   '/bar': (context) => BarScreen(),
      // },
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
