import 'package:near_me/Frontend/Features/Auth/Model/UserModel.dart';
import 'package:near_me/Frontend/Features/Auth/Repository/AuthRepo.dart';
import 'package:riverpod/riverpod.dart';

final authprovider = AsyncNotifierProvider<Authviewmodel, String?>(
  Authviewmodel.new,
);

class Authviewmodel extends AsyncNotifier<String?> {
  final _repo = AuthRepository();
  @override
  Future<String?> build() async {
    final loggedIn = await _repo.isLoggedIn();

    if (loggedIn) {
      return "Logged in";
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final token = await _repo.login(email, password);
      return token;
    });
  }

  Future<void> signup(UserModel user) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final token = await _repo.signup(user);
      return token;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.logout();  
      return null;
    });
  }
}
