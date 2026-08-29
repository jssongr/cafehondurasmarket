import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/avatar.dart';
import '../../widgets/badge.dart';
import '../../widgets/screen.dart';
import '../../widgets/stars.dart';
import '../facturacion/facturacion_screen.dart';
import '../historial/historial_screen.dart';
import '../profile/perfil_screen.dart';
import '../settings/alertas_screen.dart';
import '../settings/configuracion_screen.dart';
import '../tracking/seguimiento_screen.dart';

class _MoreItem {
  final IconData icon;
  final String label;
  final String sub;
  final WidgetBuilder builder;
  _MoreItem(this.icon, this.label, this.sub, this.builder);
}

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final rating = yo.tipo != TipoUsuario.admin ? avgRating(app.historial, usuarioId: yo.id, tipo: yo.tipo) : null;

    final items = [
      _MoreItem(Icons.location_on, 'Seguimiento GPS', 'Sigue tus viajes activos en el mapa del corredor', (_) => const SeguimientoScreen(showBack: true)),
      _MoreItem(Icons.access_time, 'Historial de viajes', 'Revisa y califica tus entregas completadas', (_) => const HistorialScreen(showBack: true)),
      _MoreItem(Icons.receipt, 'Facturación', 'Consulta tus facturas y comisiones', (_) => const FacturacionScreen(showBack: true)),
      // Solo para transportistas: al cliente no le sirve de nada avisarle de
      // cargas, es él quien las publica.
      if (yo.tipo == TipoUsuario.transportista)
        _MoreItem(Icons.notifications_active_outlined, 'Avisos de carga',
            'Te escribimos cuando publiquen carga en tus rutas', (_) => const AlertasScreen()),
      _MoreItem(Icons.person, 'Mi perfil', 'Datos personales, documentos y verificación', (_) => const PerfilScreen(showBack: true)),
      _MoreItem(Icons.settings, 'Configuración', 'Apariencia, idioma y ayuda', (_) => const ConfiguracionScreen()),
    ];

    return Screen(
      title: 'Más',
      subtitle: 'NexCarg — ${yo.subtipo}',
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
          child: Row(children: [
            Avatar(uri: yo.selfie, tipo: yo.tipo, size: 52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(yo.nombre, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navy)),
                const SizedBox(height: 3),
                Row(children: [
                  AppBadge(tone: yo.verificado ? 'verificado' : 'sinVerificar', label: yo.verificado ? 'Verificado' : 'En verificación'),
                  if (rating != null) ...[const SizedBox(width: 6), Stars(value: rating)],
                ]),
              ]),
            ),
          ]),
        ),
        Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: item.builder)),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.gris50, borderRadius: BorderRadius.circular(AppRadius.md)),
                        alignment: Alignment.center,
                        child: Icon(item.icon, size: 19, color: AppColors.navy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                          const SizedBox(height: 2),
                          Text(item.sub, style: TextStyle(fontSize: 11, color: AppColors.grisM)),
                        ]),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.grisM),
                    ]),
                  ),
                ),
              ),
          ],
        ),
        InkWell(
          onTap: app.logout,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.md)),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.logout, size: 17, color: AppColors.rojo),
              const SizedBox(width: 8),
              Text('Cerrar sesión', style: TextStyle(color: AppColors.rojo, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
        ),
      ],
    );
  }
}
