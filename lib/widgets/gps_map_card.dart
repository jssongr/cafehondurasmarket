import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../utils/format.dart';

class GpsMapCard extends StatelessWidget {
  final Carga carga;
  const GpsMapCard({super.key, required this.carga});

  @override
  Widget build(BuildContext context) {
    if (carga.lat == null || carga.lng == null) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Expanded(child: Text('Esperando la primera señal GPS del transportista…', style: TextStyle(fontSize: 11.5, color: AppColors.grisM))),
        ]),
      );
    }
    final pos = LatLng(carga.lat!, carga.lng!);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(children: [
        SizedBox(
          height: 180,
          child: FlutterMap(
            options: MapOptions(initialCenter: pos, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nexcarg.app',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: pos,
                  width: 36, height: 36,
                  child: Icon(Icons.local_shipping, color: AppColors.blue, size: 30),
                ),
              ]),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          color: AppColors.gris50,
          child: Text(
            carga.gpsActualizado != null ? 'Ubicación real · actualizada ${fmtTime(carga.gpsActualizado!)}' : 'Ubicación real',
            style: TextStyle(fontSize: 10.5, color: AppColors.grisM),
          ),
        ),
      ]),
    );
  }
}
