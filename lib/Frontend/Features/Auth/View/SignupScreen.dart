import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Features/Auth/Model/UserModel.dart';
import 'package:near_me/Frontend/Features/Auth/ViewModel/authViewModel.dart';
import 'package:near_me/Frontend/Views/CustomerMainScreen.dart';
import 'package:near_me/Frontend/Views/FreelancerDashboardScreen.dart';
import 'LoginScreen.dart';
import '../../../Theme/app_colors.dart';
import '../../../Components/custom_textfield.dart';
import '../../../Components/custom_button.dart';

class Signupscreen extends ConsumerStatefulWidget {
  const Signupscreen({super.key});

  @override
  ConsumerState<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends ConsumerState<Signupscreen> {
  bool _agreedToTerms = false;
  String _selectedRole = 'customer'; // Default role

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(authprovider);

    ref.listen(authprovider, (prev, next) {
      if (next is AsyncError) {
        String msg = next.error.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    });

    ref.listen(authprovider, (prev, next) {
      next.whenData((user) {
        if (user != null) {
          // Navigate to home after successful signup based on role
          if (user.role == 'freelancer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FreelancerDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerMainScreen()),
            );
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A342F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFD4B483),
                      size: 28,
                    ),
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
              const SizedBox(height: 32),
              const Text(
                'Create account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join NearMe Services today',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              CustomTextField(
                controller: nameController,
                label: 'Full Name',
                hintText: 'Haseeb',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: emailController,
                label: 'Email',
                hintText: 'your@email.com',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: phoneController,
                label: 'Phone Number',
                hintText: '+1 (555) 000-0000',
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: passwordController,
                label: 'Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              // Role Selection
              const Text(
                'Join as a',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'customer'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'customer'
                              ? const Color(0xFF8B5E3C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'customer'
                                ? const Color(0xFF8B5E3C)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Customer',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: _selectedRole == 'customer'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: _selectedRole == 'customer'
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'freelancer'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'freelancer'
                              ? const Color(0xFF8B5E3C)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedRole == 'freelancer'
                                ? const Color(0xFF8B5E3C)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Freelancer',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: _selectedRole == 'freelancer'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: _selectedRole == 'freelancer'
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Checklist / Terms
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) =>
                          setState(() => _agreedToTerms = val ?? false),
                      activeColor: const Color(0xFF4E342E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: Color(0xFFBCA073),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Color(0xFFBCA073),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (signupState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    CustomPrimaryButton(
                      label: 'Create Account',
                      onPressed: () {
                        // --- Input Validation ---
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final phone = phoneController.text.trim();
                        final password = passwordController.text.trim();

                        if (name.isEmpty ||
                            email.isEmpty ||
                            phone.isEmpty ||
                            password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }

                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password must be at least 6 characters',
                              ),
                            ),
                          );
                          return;
                        }

                        if (!_agreedToTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please agree to terms')),
                          );
                          return;
                        }

                        // Create User Object for signup
                        final newUser = UserModel(
                          name: name,
                          email: email,
                          password: password,
                          phoneNumber: phone,
                          role: _selectedRole,
                          createdAt: DateTime.now(),
                          skills: [],
                          location: null,
                        );

                        ref.read(authprovider.notifier).signup(newUser);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 40),

              // Login Link
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign in',
                        style: const TextStyle(
                          color: Color(0xFFBCA073),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Loginscreen(),
                              ),
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
