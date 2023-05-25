import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

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

class AutoLoginController extends GetxController {
  List<String> state = [];

  static AutoLoginController get to => Get.find<AutoLoginController>();

  void addToken(String token) {
    state = [...state, token];
  }

  void removeToken(String? token) {
    state = state.where((e) => e != token).toList();
  }

  void updateToken(String? token) {
    state[0] = token!;
  }
}
