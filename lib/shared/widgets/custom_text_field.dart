import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.suffixIcon,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  /// Optional widget placed at the trailing edge of the field.
  /// Use [GestureDetector] with [onTapDown]/[onTapUp] for hold-to-reveal.
  /// The widget is rendered outside the text-input hit area so it never
  /// accidentally focuses the field.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          autofocus: autofocus,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 14,
            ),
            // Reserve space on the right for the icon so text never overlaps.
            contentPadding: EdgeInsets.only(
              left: 18,
              right: suffixIcon != null ? 52 : 18,
              top: 18,
              bottom: 18,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: const Color(0xFF1E2126),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
        // The suffix icon sits in a separate layer so its touch area never
        // overlaps the TextFormField's focusable region.
        if (suffixIcon != null)
          Positioned(
            right: 0,
            child: SizedBox(
              width: 48,
              height: 56,
              // ExcludeFocus prevents the icon from stealing focus from the field.
              child: ExcludeFocus(child: suffixIcon!),
            ),
          ),
      ],
    );
  }
}
