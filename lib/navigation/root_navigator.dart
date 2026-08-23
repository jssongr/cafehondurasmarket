import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../screens/auth/nueva_contrasena_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../state/app_state.dart';
import 'admin_tabs.dart';
import 'cliente_tabs.dart';
import 'transportista_tabs.dart';

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.passwordRecovery) {
      return const NuevaContrasenaScreen();
    }
    if (app.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final usuario = app.usuario;
    // Quien no tiene sesión ve la presentación, no el formulario: la mayoría
    // llega desde un anuncio y todavía no sabe qué es NexCarg. El acceso y el
    // registro se abren encima desde ahí.
    if (usuario == null) return const LandingScreen();
    switch (usuario.tipo) {
      case TipoUsuario.cliente:
        return const ClienteTabs();
      case TipoUsuario.transportista:
        return const TransportistaTabs();
      case TipoUsuario.admin:
        return const AdminTabs();
    }
  }
}
