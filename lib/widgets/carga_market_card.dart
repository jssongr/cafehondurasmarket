import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/format.dart';
import 'avatar.dart';
import 'badge.dart';
import 'app_button.dart';
import 'stars.dart';

// Ya no es `const`: los colores de marca cambian con el tema claro/oscuro.
// Fijos a propósito: encima siempre va contenido blanco, así que estos
// degradados no siguen al tema. Si siguieran a la tinta, en oscuro quedaría
// blanco sobre blanco.
const Map<String, List<Color>> _headGradients = {
  'publicada': [AppColors.marcaFondo, AppColors.marcaFondo2],
  'asignada': [Color(0xFFFFB800), Color(0xFF0D47FF)],
  'en_transito': [Color(0xFF4338CA), Color(0xFF6366F1)],
  'entregada': [Color(0xFF15803D), Color(0xFF22C55E)],
  'cancelada': [Color(0xFF7F1D1D), Color(0xFFB91C1C)],
};

class CargaMarketCard extends StatelessWidget {
  final Carga carga;
  final Usuario? cliente;
  final List<HistorialItem> historial;
  final VoidCallback onPressed;
  final VoidCallback onAceptar;
  final VoidCallback onCotizar;

  const CargaMarketCard({
    super.key,
    required this.carga,
    this.cliente,
    required this.historial,
    required this.onPressed,
    required this.onAceptar,
    required this.onCotizar,
  });

  @override
  Widget build(BuildContext context) {
    final grad = _headGradients[carga.estado.value] ?? _headGradients['publicada']!;
    final rating = cliente != null ? avgRating(historial, usuarioId: cliente!.id, tipo: TipoUsuario.cliente) : null;

    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Row(
                children: [
                  Icon(tci[carga.tipoCarga] ?? Icons.inventory_2_outlined, size: 30, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${carga.peso.toStringAsFixed(0)} ${carga.unidadPeso} · ${carga.estado.value.replaceAll('_', ' ')}',
                            style: const TextStyle(fontSize: 10, color: Color(0xB3FFFFFF), letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(carga.tipoCarga, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  if (carga.peligrosa)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text('Peligrosa', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(uri: cliente?.selfie, tipo: TipoUsuario.cliente, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(carga.cliente, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                          const SizedBox(height: 3),
                          Row(children: [
                            AppBadge(tone: (cliente?.verificado ?? false) ? 'verificado' : 'sinVerificar', label: (cliente?.verificado ?? false) ? 'Verificado' : 'Sin verificar'),
                            if (cliente != null) ...[const SizedBox(width: 6), Stars(value: rating)],
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(AppRadius.sm)),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 13, color: AppColors.blue),
                      const SizedBox(width: 4),
                      Flexible(child: Text('${carga.ciudadOrigen}, ${carga.paisOrigen}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 12, color: AppColors.blue),
                      const SizedBox(width: 6),
                      Flexible(child: Text('${carga.ciudadDestino}, ${carga.paisDestino}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _row('Vehículo requerido', carga.vehiculoReq),
                _row('Fecha de recogida', carga.fecha),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    carga.presupuesto != null ? fmtMoneda(carga.presupuesto) : 'Abierto a cotización',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.blue),
                  ),
                ),
                Row(
                  children: [
                    if (carga.presupuesto != null) Expanded(child: AppButton(title: 'Aceptar viaje', size: AppButtonSize.sm, onPressed: onAceptar)),
                    if (carga.presupuesto != null) const SizedBox(width: 8),
                    Expanded(child: AppButton(title: 'Cotizar', size: AppButtonSize.sm, variant: AppButtonVariant.accent, onPressed: onCotizar)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
            const SizedBox(width: 8),
            Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navy))),
          ],
        ),
      );
}
