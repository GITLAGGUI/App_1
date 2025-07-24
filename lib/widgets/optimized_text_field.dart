import 'package:flutter/material.dart';
import '../services/ultra_fast_keyboard_manager.dart';

class OptimizedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;

  const OptimizedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onEditingComplete,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Use zero-latency TextField for maximum performance
    return UltraFastKeyboardManager.createZeroLatencyTextField(
      controller: controller,
      labelText: labelText,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.next,
      textCapitalization: textCapitalization,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}