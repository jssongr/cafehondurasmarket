import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/tab_shell.dart';
import '../theme/theme.dart';
import 'app_button.dart';

/// Lo que se ve cuando una lista está vacía.
///
/// Casi siempre hay algo que la persona podría hacer para llenarla, y decirle
/// "no tenés cargas publicadas" sin ofrecerle publicar una la deja mirando una
/// pantalla muerta. Con la plataforma recién arrancando, esta es la pantalla
/// que más gente va a ver, así que lleva el botón de la acción que sigue.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;

  /// Texto del botón. Sin él no se dibuja botón: hay listas vacías que no
  /// tienen ninguna acción sensata (el historial se llena solo).
  final String? accion;

  /// Pestaña a la que salta el botón. Ver [Pestana].
  final int? irA;

  /// Alternativa a [irA] para cuando la acción no es cambiar de pestaña.
  final VoidCallback? onAccion;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.sub,
    this.accion,
    this.irA,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.gris50, AppColors.gris100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: bordeSuperficie,
              boxShadow: sombraApoyo,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 31, color: AppColors.grisM),
          ),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy)),
          if (sub != null) ...[
            const SizedBox(height: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(sub!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.grisM)),
            ),
          ],
          if (accion != null && (irA != null || onAccion != null)) ...[
            const SizedBox(height: 18),
            AppButton(
              title: accion!,
              variant: AppButtonVariant.accent,
              size: AppButtonSize.sm,
              onPressed: onAccion ?? () => context.read<TabShellController>().goTo(irA!),
            ),
          ],
        ],
      ),
    );
  }
}
