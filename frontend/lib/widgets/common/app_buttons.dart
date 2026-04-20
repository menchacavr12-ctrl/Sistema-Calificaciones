import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GreenButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      ),
    );
  }
}

class PurpleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  const PurpleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentPurple, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.accentPurple)),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child:
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(text,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Image.network(
                'https://www.google.com/favicon.ico',
                width: 20, height: 20,
                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
              ),
        label: const Text(
          'Continuar con Google',
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}
