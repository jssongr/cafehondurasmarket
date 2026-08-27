import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/carga_list_item.dart';
import '../../navigation/tab_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';

class MisCargasScreen extends StatelessWidget {
  const MisCargasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mias = app.cargas.where((c) => c.clienteId == yo.id).toList();

    return Screen(
      title: 'Mis Cargas',
      subtitle: 'NexCarg — ${yo.subtipo}',
      children: [
        if (mias.isEmpty)
          const EmptyState(
            icon: Icons.description_outlined,
            title: 'Todavía no publicaste ninguna carga',
            sub: 'Publicar no cuesta nada y la ven todos los transportistas verificados de la ruta.',
            accion: 'Publicar mi primera carga',
            irA: Pestana.accion,
          ),
        for (final c in mias)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CargaListItem(
              carga: c,
              subtitle: '${c.ciudadOrigen} → ${c.ciudadDestino}',
              onPressed: () => openCargaDetail(context, c.id),
              actions: [
                AppButton(title: 'Ver', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: () => openCargaDetail(context, c.id)),
                if (c.estado == EstadoCarga.publicada)
                  AppButton(title: 'Cancelar', size: AppButtonSize.sm, variant: AppButtonVariant.danger, onPressed: () { app.cancelarCarga(c.id); app.showToast('Publicación cancelada'); }),
                if (c.contrato != null)
                  AppButton(title: 'Contrato', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onPressed: () => openContrato(context, c.id)),
                if ([EstadoCarga.asignada, EstadoCarga.enTransito].contains(c.estado))
                  AppButton(title: 'Seguimiento', size: AppButtonSize.sm, variant: AppButtonVariant.accent, onPressed: () => openSeguimiento(context)),
              ],
            ),
          ),
      ],
    );
  }
}
