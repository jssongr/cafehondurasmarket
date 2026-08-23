import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppButtonVariant { primary, accent, ghost, danger, outline }

enum AppButtonSize { md, sm }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final Widget? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.icon,
    this.fullWidth = false,
  });

  Color get _bg {
    switch (variant) {
      case AppButtonVariant.primary:
        // `solido` y no `navy`: el texto va en blanco encima, y `navy` en tema
        // oscuro es casi blanco.
        return AppColors.solido;
      case AppButtonVariant.accent:
        return AppColors.blue;
      case AppButtonVariant.ghost:
        return AppColors.gris100;
      case AppButtonVariant.danger:
        return AppColors.rojoBg;
      case AppButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color get _fg {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.accent:
        return Colors.white;
      case AppButtonVariant.ghost:
        return AppColors.texto;
      case AppButtonVariant.danger:
        return AppColors.rojo;
      case AppButtonVariant.outline:
        return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final child = loading
        ? SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: _fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 6)],
              Text(
                title,
                style: TextStyle(
                  color: _fg,
                  fontSize: size == AppButtonSize.sm ? 12.5 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );

    final button = Material(
      color: _bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: variant == AppButtonVariant.outline ? BorderSide(color: AppColors.navy, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: size == AppButtonSize.sm ? 9 : 13,
              horizontal: size == AppButtonSize.sm ? 14 : 20,
            ),
            child: child,
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
