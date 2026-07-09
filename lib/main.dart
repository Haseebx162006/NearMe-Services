import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:near_me/Frontend/Features/Auth/View/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
    print('Environment loaded successfully: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize Stripe with publishable key
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NearMe',
      home: const SplashScreen(),
    );
  }
}
