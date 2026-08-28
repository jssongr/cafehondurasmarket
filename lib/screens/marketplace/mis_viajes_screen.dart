import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../utils/accion.dart';
import '../../widgets/app_button.dart';
import '../../widgets/carga_list_item.dart';
import '../../navigation/tab_shell.dart';
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
        if (mios.isEmpty)
          const EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'Todavía no tenés viajes asignados',
            sub: 'Mirá las cargas publicadas en tus rutas, cotizá la que te sirva y acá te aparece el viaje.',
            accion: 'Ver cargas disponibles',
            irA: Pestana.accion,
          ),
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
                  // Tres estados, no dos: falta firmar, falta que entre el
                  // pago, o ya se puede salir. Antes el botón decía "Iniciar
                  // viaje" aunque el dinero no estuviera asegurado, y el
                  // transportista se llevaba un error al tocarlo.
                  if (c.estado == EstadoCarga.asignada)
                    if (!firmado)
                      AppButton(title: 'Firmar para iniciar', size: AppButtonSize.sm, variant: AppButtonVariant.accent, onPressed: () => openContrato(context, c.id))
                    else if (c.pago.estado != EstadoPago.retenido)
                      AppButton(title: 'Esperando el pago', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: null)
                    else
                      AppButton(
                        title: 'Iniciar viaje',
                        size: AppButtonSize.sm,
                        onPressed: () => ejecutar(
                          context,
                          () => app.iniciarViaje(c.id),
                          exito: 'Viaje iniciado — seguimiento GPS activado',
                          fallo: 'No se pudo iniciar el viaje',
                        ),
                      ),
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
