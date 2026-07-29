import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/format.dart';
import 'badge.dart';

class CargaListItem extends StatelessWidget {
  final Carga carga;
  final String subtitle;
  final VoidCallback? onPressed;
  final Widget? right;
  final List<Widget>? actions;

  const CargaListItem({super.key, required this.carga, required this.subtitle, this.onPressed, this.right, this.actions});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.md)),
              alignment: Alignment.center,
              child: Icon(tci[carga.tipoCarga] ?? Icons.inventory_2_outlined, size: 22, color: AppColors.navy),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${carga.tipoCarga} · ${carga.peso.toStringAsFixed(carga.peso % 1 == 0 ? 0 : 1)} ${carga.unidadPeso}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                  const SizedBox(height: 3),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8, runSpacing: 4,
                    children: [
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.grisM)),
                      AppBadge(tone: carga.estado.value),
                    ],
                  ),
                  if (actions != null) ...[
                    const SizedBox(height: 9),
                    Wrap(spacing: 8, runSpacing: 8, children: actions!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            right ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      carga.precioAcordado != null
                          ? fmtMoneda(carga.precioAcordado)
                          : (carga.presupuesto != null ? fmtMoneda(carga.presupuesto) : '—'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.blue),
                    ),
                    if (carga.pago.estado != EstadoPago.pendiente)
                      Text('Pago ${carga.pago.estado.value}', style: const TextStyle(fontSize: 9.5, color: AppColors.grisM)),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
