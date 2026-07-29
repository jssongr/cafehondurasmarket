import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/dashboard/transportista_dashboard.dart';
import '../screens/marketplace/cargas_disponibles_screen.dart';
import '../screens/marketplace/mis_viajes_screen.dart';
import '../screens/messages/conversations_screen.dart';
import '../screens/more/more_menu_screen.dart';
import '../state/app_state.dart';
import 'tab_shell.dart';

class TransportistaTabs extends StatelessWidget {
  const TransportistaTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final unread = app.convos.where((c) => c.participantes.contains(yo.id) && c.mensajes.any((m) => m.de != yo.id)).length;

    return TabShell(destinations: [
      TabDestination(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Panel', page: const TransportistaDashboard()),
      TabDestination(icon: Icons.storefront_outlined, activeIcon: Icons.storefront, label: 'Cargas', page: const CargasDisponiblesScreen()),
      TabDestination(icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping, label: 'Mis Viajes', page: const MisViajesScreen()),
      TabDestination(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Mensajes', page: const ConversationsScreen(), badge: unread),
      TabDestination(icon: Icons.more_horiz, activeIcon: Icons.more_horiz, label: 'Más', page: const MoreMenuScreen()),
    ]);
  }
}
