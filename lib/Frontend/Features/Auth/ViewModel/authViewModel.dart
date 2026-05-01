import 'package:geolocator/geolocator.dart';
import 'package:near_me/Frontend/Features/Search/Repository/SearchRepo.dart';
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
        await _detectAndSaveLocation();
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
        await _detectAndSaveLocation();
        return await _repo.getUserData();
      }
      return null;
    });
  }

  /// Prompts for GPS permission, gets the location, and saves it to backend.
  Future<void> _detectAndSaveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // If location services are disabled, we might not get a location,
        // but we can still try to request permission just in case.
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final searchRepo = SearchRepository();
      await searchRepo.updateUserLocation(
        longitude: position.longitude,
        latitude: position.latitude,
      );
      print('[AuthViewModel] Location saved during auth!');
    } catch (e) {
      print('[AuthViewModel] Location detection/saving failed: $e');
    }
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
