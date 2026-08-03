import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';

/// Aviso del estado de la cuenta. Cuando la rechazan o la suspenden, decir
/// "un administrador está revisando" sería mentira y dejaría al usuario
/// esperando algo que nunca va a pasar: acá se le dice el motivo real.
class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final yo = context.watch<AppState>().usuario;
    if (yo == null || yo.estadoCuenta == EstadoCuenta.aprobado) return const SizedBox.shrink();

    final (icono, titulo, texto, fondo, color) = switch (yo.estadoCuenta) {
      EstadoCuenta.rechazado => (
          Icons.error_outline,
          'Documentos rechazados',
          yo.motivoRechazo ?? 'Un administrador rechazó tus documentos. Volvé a subirlos corregidos desde Documentos.',
          AppColors.rojoBg,
          AppColors.rojo,
        ),
      EstadoCuenta.suspendido => (
          Icons.block,
          'Cuenta suspendida',
          yo.motivoRechazo ?? 'Tu cuenta fue suspendida. Escribinos a soporte si creés que es un error.',
          AppColors.rojoBg,
          AppColors.rojo,
        ),
      _ => (
          Icons.hourglass_top,
          'Cuenta en verificación',
          'Un administrador está revisando tus documentos. Te avisamos apenas quede aprobada.',
          AppColors.amberBg,
          AppColors.amberText,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icono, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(texto, style: TextStyle(fontSize: 11, color: color, height: 1.35)),
          ]),
        ),
      ]),
    );
  }
}
