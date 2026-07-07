import 'package:flutter/material.dart';
import 'dart:async';
import 'package:near_me/Frontend/Features/Auth/View/SignupScreen.dart';
import 'package:near_me/Frontend/Features/Auth/View/LoginScreen.dart';
import 'package:near_me/Frontend/Views/AdminMainScreen.dart';
import 'package:near_me/Frontend/Views/CustomerMainScreen.dart';
import 'package:near_me/Frontend/Views/FreelancerDashboardScreen.dart';
import 'package:near_me/core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late Timer _timer;
  bool _isLoggedIn = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    setState(() {
      _progress = 0.0;
    });
    const duration = Duration(seconds: 5);
    const interval = Duration(milliseconds: 50);
    int steps = duration.inMilliseconds ~/ interval.inMilliseconds;
    int currentStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      if (mounted) {
        setState(() {
          currentStep++;
          _progress = currentStep / steps;
        });
      }

      if (currentStep >= steps) {
        _timer.cancel();
        _navigateToNext();
      }
    });

    // Load data and check auth status during the 5s window
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    final role = await storage.getRole();

    // Give it at least 2 seconds for visual effect
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
        _userRole = role;
      });
      print(
        "Auth status checked: ${_isLoggedIn ? 'Logged In as $_userRole' : 'Logged Out'}",
      );
    }
  }

  void _navigateToNext() {
    if (mounted) {
      if (!_isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Loginscreen()),
        );
      } else {
        Widget nextScreen;
        final cleanRole = _userRole?.trim().toLowerCase();
        if (cleanRole == 'freelancer') {
          nextScreen = const FreelancerDashboardScreen();
        } else if (cleanRole == 'admin') {
          nextScreen = const AdminMainScreen();
        } else {
          nextScreen = const CustomerMainScreen();
        }

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => nextScreen));
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F6F1,
      ), // Cream/Off-white background matching the image
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A342F), // Dark brown color from image
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  color: Color(0xFFD4B483), // Gold/Beige color for the pin
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'NearMe ',
                    style: TextStyle(color: Color(0xFF2D2D2D)),
                  ),
                  TextSpan(
                    text: 'Services',
                    style: TextStyle(color: Color(0xFFD4AF37)), // Gold color
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  children: [
                    TextSpan(text: 'Skilled freelancers, '),
                    TextSpan(
                      text: 'within 10 km',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Loading Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A342F),
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'LOADING',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
