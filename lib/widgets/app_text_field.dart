import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppTextField extends StatefulWidget {
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
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(widget.label!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            ),
          TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText && _obscured,
            enabled: widget.enabled,
            maxLines: widget.multiline ? 4 : 1,
            minLines: widget.multiline ? 4 : 1,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            style: TextStyle(fontSize: 14.5, color: widget.enabled ? AppColors.texto : AppColors.grisM),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: const TextStyle(color: AppColors.grisM),
              filled: true,
              fillColor: widget.enabled ? AppColors.white : AppColors.gris50,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility, size: 19, color: AppColors.grisM),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
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
