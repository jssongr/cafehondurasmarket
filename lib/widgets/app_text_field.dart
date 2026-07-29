import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final bool multiline;
  final TextInputType? keyboardType;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.multiline = false,
    this.keyboardType,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(label!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            ),
          TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: multiline ? 4 : 1,
            minLines: multiline ? 4 : 1,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: TextStyle(fontSize: 14.5, color: enabled ? AppColors.texto : AppColors.grisM),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: AppColors.grisM),
              filled: true,
              fillColor: enabled ? AppColors.white : AppColors.gris50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.gris100, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.gris100, width: 1.5)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.gris100, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.amber, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
