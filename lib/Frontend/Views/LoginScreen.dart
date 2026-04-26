import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'SignupScreen.dart';
import '../Theme/app_colors.dart';
import '../Components/custom_textfield.dart';
import '../Components/social_button.dart';
import '../Components/custom_button.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6), // Warm off-white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo and Header
              Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5E3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield, color: Color(0xFF8B5E3C), size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NearMe',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Services',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue to NearMe Services',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Form Fields
              const CustomTextField(
                label: 'Email',
                hintText: 'your@email.com',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              const CustomTextField(
                label: 'Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                suffixIcon: Icon(Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(height: 20),

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) => setState(() => _rememberMe = val ?? false),
                          activeColor: const Color(0xFF4E342E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFFBCA073),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign In Button
              CustomPrimaryButton(
                label: 'Sign In',
                onPressed: () {},
              ),
              const SizedBox(height: 40),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textHint),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 32),

              // Social Buttons
              const Row(
                children: [
                  SocialButton(
                      iconPath: 'lib/Assets/google_logo.png', label: 'Google'),
                ],
              ),
              const SizedBox(height: 48),

              // Signup Link
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: const TextStyle(
                            color: Color(0xFFBCA073),
                            fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Signupscreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
