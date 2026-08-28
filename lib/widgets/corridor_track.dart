import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'mapa_flota.dart' show frescuraGps;

class CorridorTrack extends StatelessWidget {
  final Carga carga;
  const CorridorTrack({super.key, required this.carga});

  @override
  Widget build(BuildContext context) {
    final oi = paisIdx[carga.paisOrigen] ?? 0;
    final di = paisIdx[carga.paisDestino] ?? 0;
    final lo = oi < di ? oi : di;
    final hi = oi > di ? oi : di;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              _meta('Ruta: ', '${carga.ciudadOrigen} → ${carga.ciudadDestino}'),
              // Antes acá decía "Progreso: 64%" y "ETA ~4 h", dos números que
              // salían de un temporizador y no de dónde estaba el camión. Un
              // camión parado en la frontera seguía "avanzando". Lo que sí se
              // sabe es cuándo reportó por última vez.
              if (carga.estado == EstadoCarga.enTransito) _meta('GPS: ', frescuraGps(carga)),
              _meta('Pago: ', carga.pago.estado.value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) => Text.rich(
        TextSpan(children: [
          TextSpan(text: label, style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
          TextSpan(text: value, style: TextStyle(fontSize: 11.5, color: AppColors.navy, fontWeight: FontWeight.w700)),
        ]),
      );
}
