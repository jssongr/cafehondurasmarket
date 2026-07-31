import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notif_bell.dart';
import '../../widgets/screen.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/verification_banner.dart';

const Map<String, IconData> _notifIcons = {'mensaje': Icons.chat_bubble, 'oferta': Icons.attach_money, 'sistema': Icons.campaign};

class ClienteDashboard extends StatelessWidget {
  const ClienteDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mias = app.cargas.where((c) => c.clienteId == yo.id).toList();
    final activas = mias.where((c) => [EstadoCarga.publicada, EstadoCarga.asignada, EstadoCarga.enTransito].contains(c.estado)).length;
    final enTransito = mias.where((c) => c.estado == EstadoCarga.enTransito).length;
    final entregadas = mias.where((c) => c.estado == EstadoCarga.entregada).length;
    final misNotifs = app.notifs.where((n) => n.usuarioId == yo.id).toList();

    return Screen(
      title: 'Panel Principal',
      subtitle: 'NexCarg — ${yo.subtipo}',
      right: const NotifBell(),
      children: [
        if (!yo.verificado) const VerificationBanner(),
        Row(children: [
          StatTile(label: 'Cargas activas', value: '$activas', sub: 'en proceso', icon: Icons.inventory_2, accent: AppColors.amber),
          const SizedBox(width: 12),
          StatTile(label: 'En tránsito', value: '$enTransito', sub: 'en camino ahora', icon: Icons.local_shipping, accent: AppColors.indigo),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          StatTile(label: 'Entregadas', value: '$entregadas', sub: 'completadas', icon: Icons.check_circle, accent: AppColors.verde),
          const SizedBox(width: 12),
          StatTile(label: 'Notificaciones', value: '${misNotifs.where((n) => !n.leida).length}', sub: 'sin leer', icon: Icons.notifications, accent: const Color(0xFF6366F1)),
        ]),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _cardTitle('Mis cargas recientes'),
            if (mias.isEmpty) const EmptyState(icon: Icons.inventory_2_outlined, title: 'Aún no has publicado cargas'),
            for (final c in mias.reversed.take(5))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
                child: Row(children: [
                  Icon(tci[c.tipoCarga] ?? Icons.inventory_2_outlined, size: 16, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Expanded(child: Text.rich(TextSpan(children: [
                    TextSpan(text: c.tipoCarga, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.texto)),
                    TextSpan(text: ' · ${c.ciudadOrigen}, ${c.paisOrigen} → ${c.ciudadDestino}, ${c.paisDestino}', style: const TextStyle(color: AppColors.texto)),
                  ]), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5))),
                  const SizedBox(width: 8),
                  AppBadge(tone: c.estado.value),
                ]),
              ),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _cardTitle('Actividad reciente'),
            if (misNotifs.isEmpty) const EmptyState(icon: Icons.notifications_none, title: 'Sin actividad reciente'),
            for (final n in misNotifs.take(5))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(_notifIcons[n.tipo] ?? Icons.campaign, size: 16, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.titulo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    Text(n.sub, style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
                    Text(fmtTime(n.ts), style: const TextStyle(fontSize: 10, color: AppColors.grisM)),
                  ])),
                ]),
              ),
          ]),
        ),
      ],
    );
  }

  Widget _cardTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
          child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy)),
        ),
      );
}
