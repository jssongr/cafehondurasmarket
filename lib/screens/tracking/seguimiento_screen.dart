import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/badge.dart';
import '../../widgets/corridor_track.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gps_map_card.dart';
import '../../widgets/tarjeta_rastreo.dart';
import '../../widgets/screen.dart';

class SeguimientoScreen extends StatelessWidget {
  final bool showBack;
  const SeguimientoScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mios = app.cargas.where((c) {
      final esParticipante = yo.tipo == TipoUsuario.cliente ? c.clienteId == yo.id : c.transportistaId == yo.id;
      return esParticipante && [EstadoCarga.asignada, EstadoCarga.enTransito].contains(c.estado);
    }).toList();

    return Screen(
      title: 'Seguimiento GPS',
      subtitle: 'NexCarg — ${yo.subtipo}',
      onBack: showBack ? () => Navigator.of(context).pop() : null,
      children: [
        const TarjetaRastreo(),
        if (mios.isEmpty)
          const EmptyState(
            icon: Icons.location_on_outlined,
            title: 'No tenés viajes en curso',
            sub: 'Cuando una carga salga, acá vas a ver dónde está en el mapa, en vivo.',
          ),
        for (final c in mios)
          Builder(builder: (context) {
            final firmado = c.contrato?.ambosFirmaron ?? false;
            return AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(tci[c.tipoCarga] ?? Icons.inventory_2_outlined, size: 16, color: AppColors.navy),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${c.tipoCarga} · ${c.peso.toStringAsFixed(0)} ${c.unidadPeso}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy))),
                      ]),
                      const SizedBox(height: 3),
                      Text('${c.ciudadOrigen}, ${c.paisOrigen} → ${c.ciudadDestino}, ${c.paisDestino}', style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                      Text(yo.tipo == TipoUsuario.cliente ? 'Transportista: ${c.transportistaNombre}' : 'Cliente: ${c.cliente}', style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                    ]),
                  ),
                  AppBadge(tone: c.estado.value, label: c.estado == EstadoCarga.asignada ? 'Esperando inicio' : 'En tránsito'),
                ]),
                CorridorTrack(carga: c),
                if (c.estado == EstadoCarga.enTransito) GpsMapCard(carga: c),
                if (yo.tipo == TipoUsuario.transportista && c.estado == EstadoCarga.asignada)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: firmado
                        ? AppButton(title: 'Iniciar viaje', size: AppButtonSize.sm, onPressed: () => app.iniciarViaje(c.id))
                        : AppButton(title: 'Firmar contrato para iniciar', size: AppButtonSize.sm, variant: AppButtonVariant.accent, onPressed: () => openContrato(context, c.id)),
                  ),
                if (yo.tipo == TipoUsuario.transportista && c.estado == EstadoCarga.enTransito)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AppButton(title: 'Confirmar entrega', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: () => openPruebaEntrega(context, c.id)),
                  ),
              ]),
            );
          }),
      ],
    );
  }
}
