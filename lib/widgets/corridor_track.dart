import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';

class CorridorTrack extends StatelessWidget {
  final Carga carga;
  const CorridorTrack({super.key, required this.carga});

  @override
  Widget build(BuildContext context) {
    final oi = paisIdx[carga.paisOrigen] ?? 0;
    final di = paisIdx[carga.paisDestino] ?? 0;
    final lo = oi < di ? oi : di;
    final hi = oi > di ? oi : di;
    final pos = oi + (di - oi) * (carga.progreso / 100);
    final pct = (pos / (paises.length - 1)).clamp(0.0, 1.0);
    final eta = carga.estado == EstadoCarga.enTransito ? ((100 - carga.progreso) / 10).round().clamp(1, 999) : null;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              return SizedBox(
                height: 20,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 7, left: 0, right: 0,
                      child: Container(height: 6, decoration: BoxDecoration(color: AppColors.gris100, borderRadius: BorderRadius.circular(3))),
                    ),
                    Positioned(
                      top: 7, left: 0,
                      child: Container(width: w * pct, height: 6, decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(3))),
                    ),
                    Positioned(
                      top: -2, left: (w * pct - 10).clamp(0.0, w - 20),
                      child: const Icon(Icons.local_shipping, size: 20, color: AppColors.blue),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(paises.length, (i) {
              final active = i >= lo && i <= hi;
              return Expanded(
                child: Column(
                  children: [
                    Container(width: 8, height: 8, margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(color: active ? AppColors.blue : AppColors.gris300, shape: BoxShape.circle)),
                    Text(paises[i], textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 8.5, fontWeight: active ? FontWeight.w800 : FontWeight.w600, color: active ? AppColors.navy : AppColors.grisM)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg, runSpacing: 6,
            children: [
              _meta('Progreso: ', '${carga.progreso.round()}%'),
              if (eta != null) _meta('ETA: ', '~$eta h'),
              _meta('Pago: ', carga.pago.estado.value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) => Text.rich(
        TextSpan(children: [
          TextSpan(text: label, style: const TextStyle(fontSize: 11.5, color: AppColors.grisM)),
          TextSpan(text: value, style: const TextStyle(fontSize: 11.5, color: AppColors.navy, fontWeight: FontWeight.w700)),
        ]),
      );
}
