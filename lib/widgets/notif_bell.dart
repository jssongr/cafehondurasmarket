import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/theme.dart';
import '../utils/format.dart';
import 'empty_state.dart';

const Map<String, IconData> _notifIcons = {'mensaje': Icons.chat_bubble, 'oferta': Icons.attach_money, 'sistema': Icons.campaign};

class NotifBell extends StatelessWidget {
  final VoidCallback? onOpenMensajes;
  const NotifBell({super.key, this.onOpenMensajes});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final mis = app.notifs.where((n) => n.usuarioId == yo.id).toList();
    final unread = mis.where((n) => !n.leida).length;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        app.markNotifsRead(yo.id);
        showDialog(
          context: context,
          barrierColor: const Color(0x660F2942),
          builder: (ctx) => Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 60, right: AppSpacing.lg),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  constraints: const BoxConstraints(maxHeight: 460),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: floatingShadow),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gris100))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Notificaciones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                            InkWell(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 18, color: AppColors.grisM)),
                          ],
                        ),
                      ),
                      Flexible(
                        child: mis.isEmpty
                            ? const EmptyState(icon: Icons.notifications_none, title: 'Sin notificaciones')
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: mis.length,
                                itemBuilder: (c, i) {
                                  final n = mis[i];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      if ((n.tipo == 'mensaje' || n.tipo == 'oferta') && onOpenMensajes != null) onOpenMensajes!();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.lg),
                                      decoration: BoxDecoration(
                                        color: n.leida ? null : const Color(0xFFFFFBF2),
                                        border: const Border(bottom: BorderSide(color: AppColors.gris100)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(_notifIcons[n.tipo] ?? Icons.campaign, size: 18, color: AppColors.navy),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(n.titulo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navy)),
                                                const SizedBox(height: 2),
                                                Text(n.sub, style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
                                                const SizedBox(height: 3),
                                                Text(fmtTime(n.ts), style: const TextStyle(fontSize: 10, color: AppColors.grisM)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle, boxShadow: cardShadow),
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_none, size: 22, color: AppColors.navy),
          ),
          if (unread > 0)
            Positioned(
              top: 8, right: 9,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: AppColors.rojo, shape: BoxShape.circle, border: Border.all(color: AppColors.white, width: 1.5)),
              ),
            ),
        ],
      ),
    );
  }
}
