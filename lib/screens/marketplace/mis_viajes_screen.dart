import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/carga_list_item.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';

class MisViajesScreen extends StatelessWidget {
  const MisViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mios = app.cargas.where((c) => c.transportistaId == yo.id).toList();

    return Screen(
      title: 'Mis Viajes',
      subtitle: 'NexCarg — ${yo.subtipo}',
      children: [
        if (mios.isEmpty) const EmptyState(icon: Icons.local_shipping_outlined, title: 'Aún no tienes viajes asignados', sub: 'Acepta o cotiza una carga en "Cargas Disponibles"'),
        for (final c in mios)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Builder(builder: (context) {
              final firmado = c.contrato?.ambosFirmaron ?? false;
              return CargaListItem(
                carga: c,
                subtitle: '${c.cliente} · Recogida ${c.fecha}',
                onPressed: () => openCargaDetail(context, c.id),
                actions: [
                  AppButton(title: 'Ver', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: () => openCargaDetail(context, c.id)),
                  if (c.contrato != null)
                    AppButton(title: 'Contrato', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: () => openContrato(context, c.id)),
                  if (c.estado == EstadoCarga.asignada)
                    firmado
                        ? AppButton(title: 'Iniciar viaje', size: AppButtonSize.sm, onPressed: () { app.iniciarViaje(c.id); app.showToast('Viaje iniciado — seguimiento GPS activado'); })
                        : AppButton(title: 'Firmar para iniciar', size: AppButtonSize.sm, variant: AppButtonVariant.accent, onPressed: () => openContrato(context, c.id)),
                  if (c.estado == EstadoCarga.enTransito) ...[
                    AppButton(title: 'Seguimiento', size: AppButtonSize.sm, variant: AppButtonVariant.accent, onPressed: () => openSeguimiento(context)),
                    AppButton(title: 'Confirmar entrega', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: () => openPruebaEntrega(context, c.id)),
                  ],
                ],
              );
            }),
          ),
      ],
    );
  }
}
