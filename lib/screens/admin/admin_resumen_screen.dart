import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/badge.dart';
import '../../widgets/notif_bell.dart';
import '../../widgets/screen.dart';
import '../../widgets/stat_tile.dart';

class AdminResumenScreen extends StatelessWidget {
  const AdminResumenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final users = app.usuarios.where((u) => u.tipo != TipoUsuario.admin).toList();
    final activos = app.cargas.where((c) => c.estado == EstadoCarga.enTransito).length;
    final comision = app.facturas.fold<double>(0, (a, f) => a + f.comision);

    return Screen(
      title: 'Resumen',
      subtitle: 'NexCarg — ${yo.subtipo}',
      right: const NotifBell(),
      children: [
        Row(children: [
          StatTile(label: 'Usuarios', value: '${users.length}', sub: 'clientes y transportistas', icon: Icons.people, accent: AppColors.amber),
          const SizedBox(width: 12),
          StatTile(label: 'En tránsito', value: '$activos', sub: 'ahora mismo', icon: Icons.local_shipping, accent: AppColors.indigo),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          StatTile(label: 'Completados', value: '${app.historial.length}', sub: 'entregados', icon: Icons.check_circle, accent: AppColors.verde),
          const SizedBox(width: 12),
          StatTile(label: 'Comisión', value: fmtMoneda(comision), sub: '$comisionTexto% por viaje', icon: Icons.attach_money, accent: const Color(0xFF6366F1)),
        ]),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _title('Usuarios recientes'),
            for (final u in users.reversed.take(5))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
                child: Row(children: [
                  Icon(tipoIcon[u.tipo], size: 16, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Expanded(child: Text.rich(TextSpan(children: [
                    TextSpan(text: u.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ' · ${u.subtipo}'),
                  ]), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.texto))),
                  const SizedBox(width: 8),
                  AppBadge(tone: u.verificado ? 'verificado' : 'sinVerificar', label: u.verificado ? 'Verificado' : 'Sin verificar'),
                ]),
              ),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _title('Viajes recientes'),
            for (final c in app.cargas.reversed.take(5))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
                child: Row(children: [
                  Expanded(child: Text.rich(TextSpan(children: [
                    TextSpan(text: c.tipoCarga, style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: ' · ${c.ciudadOrigen}, ${c.paisOrigen} → ${c.ciudadDestino}, ${c.paisDestino}'),
                  ]), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: AppColors.texto))),
                  AppBadge(tone: c.estado.value),
                ]),
              ),
          ]),
        ),
      ],
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
          child: Text(t, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy)),
        ),
      );
}
