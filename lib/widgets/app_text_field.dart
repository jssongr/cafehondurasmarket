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
              child: Text(widget.label!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            ),
          // El campo va hundido, no plano: se rellena con el gris suave y la
          // sombra le entra desde arriba, como un surco. Así el formulario se
          // lee como una superficie con huecos donde escribir, en vez de como
          // rectángulos apoyados sobre otro rectángulo.
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.marcaFondo.withValues(alpha: AppColors.esOscuro ? 0.3 : 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: TextField(
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
              hintStyle: TextStyle(color: AppColors.grisM),
              filled: true,
              fillColor: widget.enabled ? AppColors.gris50 : AppColors.gris100,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(_obscured ? Icons.visibility_off : Icons.visibility, size: 19, color: AppColors.grisM),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.gris100, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.gris100, width: 1.5)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.gris100, width: 1.5)),
              // Al enfocar manda el azul de acción, no el ámbar: el ámbar es
              // el color de "atención" en el resto de la app y acá confundía.
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.blue, width: 1.8)),
            ),
          ),
          ),
        ],
      ),
    );
  }
}
