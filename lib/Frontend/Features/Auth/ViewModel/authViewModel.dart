import 'package:near_me/Frontend/Features/Auth/Model/UserModel.dart';
import 'package:near_me/Frontend/Features/Auth/Repository/AuthRepo.dart';
import 'package:riverpod/riverpod.dart';

final authprovider = AsyncNotifierProvider<Authviewmodel, UserModel?>(
  Authviewmodel.new,
);

class Authviewmodel extends AsyncNotifier<UserModel?> {
  final _repo = AuthRepository();
  @override
  Future<UserModel?> build() async {
    final loggedIn = await _repo.isLoggedIn();

    if (loggedIn) {
      return await _repo.getUserData();
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final token = await _repo.login(email, password);
      if (token != null) {
        return await _repo.getUserData();
      }
      return null;
    });
  }

  Future<void> signup(UserModel user) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final token = await _repo.signup(user);
      if (token != null) {
        return await _repo.getUserData();
      }
      return null;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.logout();
      return null;
    });
  }

  /// Resets the state back to initial (no error, no loading).
  /// Call this when the user wants to try again after a failed signup/login.
  void resetState() {
    state = const AsyncData(null);
  }

  Future<String?> getName() async {
    return await _repo.getName();
  }
}
