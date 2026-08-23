import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppButtonVariant { primary, accent, ghost, danger, outline }

enum AppButtonSize { md, sm }

/// Botón con volumen: degradado, filo de luz arriba, resplandor de su propio
/// color, y un hundido al presionar. Ese hundido —la sombra se achica y la
/// pieza baja un pixel— es lo que hace que se sienta como un botón físico y no
/// como un rectángulo que cambia de tono.
class AppButton extends StatefulWidget {
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

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _presionado = false;

  bool get _deshabilitado => widget.onPressed == null || widget.loading;

  /// Los que se rellenan con un color fuerte llevan contenido blanco encima.
  bool get _relleno =>
      widget.variant == AppButtonVariant.primary || widget.variant == AppButtonVariant.accent;

  Gradient? get _degradado => switch (widget.variant) {
        AppButtonVariant.primary => LinearGradient(
            colors: [Color.lerp(AppColors.solido, Colors.white, 0.16)!, AppColors.solido],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        AppButtonVariant.accent => degradadoAzul,
        _ => null,
      };

  Color? get _fondo => switch (widget.variant) {
        AppButtonVariant.ghost => AppColors.gris50,
        AppButtonVariant.danger => AppColors.rojoBg,
        AppButtonVariant.outline => Colors.transparent,
        _ => null,
      };

  Color get _fg => switch (widget.variant) {
        AppButtonVariant.primary || AppButtonVariant.accent => Colors.white,
        AppButtonVariant.ghost => AppColors.texto,
        AppButtonVariant.danger => AppColors.rojo,
        AppButtonVariant.outline => AppColors.navy,
      };

  List<BoxShadow> get _sombra {
    if (_deshabilitado || _presionado) return const [];
    return switch (widget.variant) {
      AppButtonVariant.primary => cardShadow,
      AppButtonVariant.accent => resplandor(AppColors.blue, fuerza: 0.42),
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(AppRadius.md);
    final pequeno = widget.size == AppButtonSize.sm;

    final contenido = widget.loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: _fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 6)],
              Text(
                widget.title,
                style: TextStyle(
                  color: _fg,
                  fontSize: pequeno ? 12.5 : 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          );

    final boton = AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      // Baja un pixel al presionarse. Sin esto el botón cambia de sombra pero
      // no se mueve, y el efecto se lee como un parpadeo en vez de un empuje.
      transform: Matrix4.translationValues(0, _presionado ? 1.5 : 0, 0),
      decoration: BoxDecoration(
        color: _fondo,
        gradient: _degradado,
        borderRadius: radio,
        border: widget.variant == AppButtonVariant.outline
            ? Border.all(color: AppColors.gris300, width: 1.5)
            : (_relleno
                // Filo claro arriba y oscuro abajo: es el canto del botón.
                ? Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.22), width: 1),
                    bottom: BorderSide(color: Colors.black.withValues(alpha: 0.16), width: 1),
                  )
                : null),
        boxShadow: _sombra,
      ),
      child: Padding(
        // El contorno lleva un borde de 1.5 que suma 3 px de alto. Sin quitarlos
        // del relleno, un botón de contorno al lado de uno normal queda más alto
        // y la fila se ve desalineada.
        padding: EdgeInsets.symmetric(
          vertical: (pequeno ? 9 : 13) - (widget.variant == AppButtonVariant.outline ? 1.5 : 0),
          horizontal: pequeno ? 14 : 20,
        ),
        child: contenido,
      ),
    );

    final envuelto = Opacity(opacity: _deshabilitado ? 0.45 : 1, child: boton);

    final tocable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _deshabilitado ? null : widget.onPressed,
        onTapDown: (_) => setState(() => _presionado = true),
        onTapUp: (_) => setState(() => _presionado = false),
        onTapCancel: () => setState(() => _presionado = false),
        borderRadius: radio,
        child: envuelto,
      ),
    );

    return widget.fullWidth ? SizedBox(width: double.infinity, child: tocable) : tocable;
  }
}
