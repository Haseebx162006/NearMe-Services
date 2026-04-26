import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF4E342E),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
