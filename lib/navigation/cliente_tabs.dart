import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/dashboard/cliente_dashboard.dart';
import '../screens/marketplace/mis_cargas_screen.dart';
import '../screens/marketplace/publicar_carga_screen.dart';
import '../screens/messages/conversations_screen.dart';
import '../screens/more/more_menu_screen.dart';
import '../state/app_state.dart';
import 'tab_shell.dart';

class ClienteTabs extends StatelessWidget {
  const ClienteTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final unread = app.convos.where((c) => c.participantes.contains(yo.id) && c.mensajes.any((m) => m.de != yo.id)).length;

    return TabShell(destinations: [
      TabDestination(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Panel', page: const ClienteDashboard()),
      TabDestination(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Publicar', page: const PublicarCargaScreen()),
      TabDestination(icon: Icons.folder_open_outlined, activeIcon: Icons.folder, label: 'Mis Cargas', page: const MisCargasScreen()),
      TabDestination(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Mensajes', page: const ConversationsScreen(), badge: unread),
      TabDestination(icon: Icons.more_horiz, activeIcon: Icons.more_horiz, label: 'Más', page: const MoreMenuScreen()),
    ]);
  }
}
