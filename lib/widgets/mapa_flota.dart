import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/format.dart';

/// Todos los viajes en tránsito sobre un mismo mapa. El mapa de cada viaje
/// individual solo lo ven sus dos partes; esta es la vista de operaciones, para
/// saber de un vistazo dónde está la flota completa.
class MapaFlota extends StatelessWidget {
  final List<Carga> cargas;
  final void Function(Carga) onTocarCarga;

  const MapaFlota({super.key, required this.cargas, required this.onTocarCarga});

  @override
  Widget build(BuildContext context) {
    final conGps = cargas.where((c) => c.lat != null && c.lng != null).toList();
    final sinGps = cargas.length - conGps.length;

    if (conGps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(children: [
          const Icon(Icons.map_outlined, size: 30, color: AppColors.grisM),
          const SizedBox(height: 8),
          Text(
            cargas.isEmpty ? 'No hay viajes en tránsito ahora mismo' : 'Ningún viaje ha enviado su ubicación todavía',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navy),
          ),
          const SizedBox(height: 4),
          const Text(
            'La ubicación llega del teléfono del transportista mientras tiene la app abierta.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.grisM, height: 1.35),
          ),
        ]),
      );
    }

    final puntos = conGps.map((c) => LatLng(c.lat!, c.lng!)).toList();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
      child: Column(children: [
        SizedBox(
          height: 300,
          child: FlutterMap(
            options: MapOptions(
              // Encuadra la flota entera; con un solo camión, LatLngBounds de un
              // punto deja el zoom sin definir, así que ahí se centra a mano.
              initialCameraFit: puntos.length > 1
                  ? CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(puntos),
                      padding: const EdgeInsets.all(48),
                      maxZoom: 11,
                    )
                  : null,
              initialCenter: puntos.first,
              initialZoom: puntos.length > 1 ? 6 : 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nexcarg.app',
              ),
              MarkerLayer(
                markers: [
                  for (final c in conGps)
                    Marker(
                      point: LatLng(c.lat!, c.lng!),
                      width: 132,
                      height: 54,
                      child: _MarcadorCamion(carga: c, onTap: () => onTocarCarga(c)),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: AppColors.white,
          child: Row(children: [
            const Icon(Icons.circle, size: 8, color: AppColors.verde),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${conGps.length} en el mapa'
                '${sinGps > 0 ? ' · $sinGps sin señal GPS' : ''}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navy),
              ),
            ),
            const Text('Tocá un camión para ver el viaje',
                style: TextStyle(fontSize: 10.5, color: AppColors.grisM)),
          ]),
        ),
      ]),
    );
  }
}

class _MarcadorCamion extends StatelessWidget {
  final Carga carga;
  final VoidCallback onTap;
  const _MarcadorCamion({required this.carga, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Más de 15 minutos sin reportar suele significar que cerró la app.
    final desfasado = carga.gpsActualizado == null ||
        DateTime.now().difference(carga.gpsActualizado!).inMinutes > 15;

    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            carga.transportistaNombre ?? 'Sin asignar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: desfasado ? AppColors.grisM : AppColors.blue,
            shape: BoxShape.circle,
            boxShadow: floatingShadow,
          ),
          child: const Icon(Icons.local_shipping, size: 16, color: Colors.white),
        ),
      ]),
    );
  }
}

/// Texto corto sobre cuán fresca es la última posición.
String frescuraGps(Carga c) =>
    c.gpsActualizado == null ? 'sin señal GPS' : 'visto ${fmtTime(c.gpsActualizado!)}';
