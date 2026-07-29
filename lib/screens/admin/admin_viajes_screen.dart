import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/carga_list_item.dart';
import '../../widgets/screen.dart';

class AdminViajesScreen extends StatelessWidget {
  const AdminViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;

    return Screen(
      title: 'Viajes',
      subtitle: 'NexCarg — ${yo.subtipo}',
      children: [
        for (final c in app.cargas)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CargaListItem(
              carga: c,
              subtitle: '${c.cliente} → ${c.transportistaNombre ?? "sin asignar"}',
              onPressed: () => openCargaDetail(context, c.id),
            ),
          ),
      ],
    );
  }
}
