import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mis = app.convos.where((c) => c.participantes.contains(yo.id)).toList();

    Usuario? otro(Conversacion c) {
      final otroId = c.participantes.firstWhere((p) => p != yo.id, orElse: () => '');
      if (otroId.isEmpty) return null;
      return app.perfilDe(otroId);
    }

    return Screen(
      title: 'Mensajes',
      subtitle: '${mis.length} conversaciones',
      children: [
        if (mis.isEmpty)
          const EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Sin conversaciones todavía',
            sub: 'Cuando contactes a alguien por una carga, la conversación queda guardada acá.',
          ),
        for (final c in mis)
          Builder(builder: (context) {
            final o = otro(c);
            final last = c.mensajes.isNotEmpty ? c.mensajes.last : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => openChat(context, c.id),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: cardShadow),
                  child: Row(children: [
                    Avatar(uri: o?.selfie, tipo: o?.tipo ?? TipoUsuario.cliente, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(o?.nombre ?? 'Usuario', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                          if (last != null) Text(fmtTime(last.ts), style: TextStyle(fontSize: 10.5, color: AppColors.grisM)),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          last == null ? 'Sin mensajes' : (last.esOferta ? 'Cotización: ${fmtMoneda(last.precio)}' : (last.texto ?? '')),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: AppColors.grisM),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            );
          }),
      ],
    );
  }
}
