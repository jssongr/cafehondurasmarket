import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';
import '../../widgets/stars.dart';
import '../modals/calificar_modal.dart';

class HistorialScreen extends StatelessWidget {
  final bool showBack;
  const HistorialScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mis = app.historial.where((h) => h.clienteId == yo.id || h.transportistaId == yo.id).toList();

    return Screen(
      title: 'Historial de Viajes',
      subtitle: 'NexCarg — ${yo.subtipo}',
      onBack: showBack ? () => Navigator.of(context).pop() : null,
      children: [
        if (mis.isEmpty) const EmptyState(icon: Icons.access_time, title: 'Sin viajes completados', sub: 'Las entregas confirmadas aparecerán aquí'),
        for (final h in mis)
          Builder(builder: (context) {
            final miCal = yo.tipo == TipoUsuario.cliente ? h.calTransportista : h.calCliente;
            final suCal = yo.tipo == TipoUsuario.cliente ? h.calCliente : h.calTransportista;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.md)),
                  alignment: Alignment.center,
                  child: Icon(tci[h.tipoCarga] ?? Icons.inventory_2_outlined, size: 20, color: AppColors.navy),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${h.tipoCarga} · ${yo.tipo == TipoUsuario.cliente ? "Transportado por ${h.transportista}" : "Para ${h.cliente}"}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 3),
                    Text(h.ruta, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Text(h.fecha, style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
                      const SizedBox(width: 8),
                      const AppBadge(tone: 'entregada', label: 'completado'),
                    ]),
                    if (suCal != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Te calificaron: ${suCal.estrellas}/5 "${suCal.comentario}"', style: const TextStyle(fontSize: 10.5, color: AppColors.grisM)),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: miCal != null
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              const Text('Tu calificación:', style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                              const SizedBox(width: 6),
                              Stars(value: miCal.estrellas.toDouble()),
                            ])
                          : AppButton(
                              title: 'Calificar', size: AppButtonSize.sm, variant: AppButtonVariant.accent,
                              onPressed: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => CalificarModal(historialId: h.id))),
                            ),
                    ),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(fmtMoneda(h.monto), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.blue)),
                  const Text('Pago liberado', style: TextStyle(fontSize: 9.5, color: AppColors.grisM)),
                ]),
              ]),
            );
          }),
      ],
    );
  }
}
