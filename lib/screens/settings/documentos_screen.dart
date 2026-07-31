import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen.dart';

class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    final tieneDocs = yo.doc != null || yo.docIdentidad != null || yo.selfie != null;

    return Screen(
      title: 'Documentos',
      subtitle: 'Tus archivos de verificación',
      onBack: () => Navigator.of(context).pop(),
      children: [
        if (!tieneDocs) const EmptyState(icon: Icons.folder_open, title: 'Sin documentos cargados', sub: 'Se suben durante el registro'),
        if (yo.doc != null)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(yo.tipo == TipoUsuario.transportista ? 'Licencia de conducir' : 'Documento de la empresa', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                AppBadge(tone: yo.verificado ? 'verificado' : 'sinVerificar', label: yo.verificado ? 'Aprobado' : 'En revisión'),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md), child: AppImage(path: yo.doc!, width: double.infinity, height: 160)),
            ]),
          ),
        if (yo.docIdentidad != null)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Documento de identidad (DNI/cédula)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                AppBadge(tone: yo.verificado ? 'verificado' : 'sinVerificar', label: yo.verificado ? 'Aprobado' : 'En revisión'),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md), child: AppImage(path: yo.docIdentidad!, width: double.infinity, height: 160)),
            ]),
          ),
        if (yo.selfie != null)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Selfie de verificación', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy))),
                AppBadge(tone: yo.verificado ? 'verificado' : 'sinVerificar', label: yo.verificado ? 'Aprobado' : 'En revisión'),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(AppRadius.md), child: AppImage(path: yo.selfie!, width: double.infinity, height: 160)),
            ]),
          ),
      ],
    );
  }
}
