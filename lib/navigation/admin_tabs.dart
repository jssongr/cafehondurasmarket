import 'package:flutter/material.dart';
import '../screens/admin/admin_resumen_screen.dart';
import '../screens/admin/admin_usuarios_screen.dart';
import '../screens/admin/admin_viajes_screen.dart';
import '../screens/facturacion/facturacion_screen.dart';
import '../screens/profile/perfil_screen.dart';
import 'tab_shell.dart';

class AdminTabs extends StatelessWidget {
  const AdminTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return TabShell(destinations: [
      TabDestination(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Resumen', page: const AdminResumenScreen()),
      TabDestination(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Usuarios', page: const AdminUsuariosScreen()),
      TabDestination(icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping, label: 'Viajes', page: const AdminViajesScreen()),
      TabDestination(icon: Icons.receipt_outlined, activeIcon: Icons.receipt, label: 'Facturas', page: const FacturacionScreen(modoAdmin: true)),
      TabDestination(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Perfil', page: const PerfilScreen()),
    ]);
  }
}
