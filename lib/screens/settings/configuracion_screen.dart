import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/screen.dart';
import '../facturacion/facturacion_screen.dart';
import '../historial/historial_screen.dart';
import 'ayuda_screen.dart';
import 'documentos_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Screen(
      title: 'Configuración',
      subtitle: 'Preferencias de la app',
      onBack: () => Navigator.of(context).pop(),
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('APARIENCIA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            const SizedBox(height: 12),
            Row(children: [
              _themeChip(context, 'Claro', Icons.light_mode, ThemeMode.light, app.themeMode),
              const SizedBox(width: 8),
              _themeChip(context, 'Oscuro', Icons.dark_mode, ThemeMode.dark, app.themeMode),
              const SizedBox(width: 8),
              _themeChip(context, 'Automático', Icons.brightness_auto, ThemeMode.system, app.themeMode),
            ]),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('IDIOMA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            const SizedBox(height: 12),
            Row(children: [
              _idiomaChip(context, 'Español', 'ES', app.idioma),
              const SizedBox(width: 8),
              _idiomaChip(context, 'English', 'EN', app.idioma),
            ]),
            if (app.idioma == 'EN')
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('La traducción completa al inglés todavía no está disponible — por ahora el contenido sigue en español.',
                    style: TextStyle(fontSize: 11, color: AppColors.grisM, height: 1.4)),
              ),
          ]),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            _link(context, Icons.help_outline, 'Ayuda', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AyudaScreen()))),
            _divider(),
            _link(context, Icons.access_time, 'Historial', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistorialScreen(showBack: true)))),
            _divider(),
            _link(context, Icons.receipt_long, 'Facturación', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FacturacionScreen(showBack: true)))),
            _divider(),
            _link(context, Icons.folder_outlined, 'Documentos', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentosScreen())), isLast: true),
          ]),
        ),
      ],
    );
  }

  Widget _themeChip(BuildContext context, String label, IconData icon, ThemeMode mode, ThemeMode current) {
    final on = mode == current;
    return Expanded(
      child: InkWell(
        onTap: () => context.read<AppState>().setThemeMode(mode),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: on ? AppColors.navy : AppColors.gris50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(children: [
            Icon(icon, size: 18, color: on ? Colors.white : AppColors.grisM),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.grisM)),
          ]),
        ),
      ),
    );
  }

  Widget _idiomaChip(BuildContext context, String label, String code, String current) {
    final on = code == current;
    return Expanded(
      child: InkWell(
        onTap: () => context.read<AppState>().setIdioma(code),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: on ? AppColors.navy : AppColors.gris50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.grisM)),
        ),
      ),
    );
  }

  Widget _link(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isLast = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(children: [
          Icon(icon, size: 19, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.navy))),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.grisM),
        ]),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.gris100);
}
