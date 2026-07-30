import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/avatar.dart';
import '../../widgets/badge.dart';
import '../../widgets/screen.dart';
import '../../widgets/stars.dart';

class AdminUsuariosScreen extends StatelessWidget {
  const AdminUsuariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final users = app.usuarios.where((u) => u.tipo != TipoUsuario.admin).toList();

    return Screen(
      title: 'Usuarios',
      subtitle: 'NexCarg — ${yo.subtipo}',
      children: [
        for (final u in users)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Avatar(uri: u.selfie, tipo: u.tipo, size: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 2),
                    Text('${u.subtipo} · ${u.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  AppBadge(tone: u.verificado ? 'verificado' : 'sinVerificar', label: u.verificado ? 'Verificado' : 'En verificación'),
                  const SizedBox(height: 4),
                  Stars(value: avgRating(app.historial, usuarioId: u.id, tipo: u.tipo)),
                ]),
              ]),
              if (!u.verificado)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: AppButton(
                    title: 'Aprobar documentos', size: AppButtonSize.sm, fullWidth: true,
                    icon: const Icon(Icons.check_circle_outline, size: 15, color: Colors.white),
                    onPressed: () {
                      app.aprobarUsuario(u.id);
                      app.showToast('Cuenta de ${u.nombre} verificada');
                    },
                  ),
                ),
            ]),
          ),
      ],
    );
  }
}
