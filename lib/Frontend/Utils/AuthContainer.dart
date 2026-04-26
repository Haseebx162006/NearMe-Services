import 'package:flutter/material.dart';
import 'package:near_me/Frontend/Theme/app_colors.dart';

// reusable auth container for signup and login screen
class Authcontainer extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool obsecureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon; 
  final IconData? suffixIcon;
  final IconData? icon;
  const Authcontainer({
    super.key,
    required this.title,
    required this.controller,
    this.obsecureText = false,
    this.keyboardType,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<Authcontainer> createState() => _AuthcontainerState();
}

class _AuthcontainerState extends State<Authcontainer> {
  late bool _obsecure;
  @override
  void initState() {
    _obsecure = widget.obsecureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
     controller: widget.controller,
      obscureText: _obsecure,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintText: widget.title,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textHint,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textHint, size: 20)
            : null,
        suffixIcon: widget.obsecureText
            ? IconButton(
                icon: Icon(
                  _obsecure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textHint,
                  size: 20,
                ),
                onPressed: () => setState(() => _obsecure = !_obsecure),
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
