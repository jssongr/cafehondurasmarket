import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/badge.dart';
import '../../widgets/screen.dart';
import '../../widgets/stars.dart';

String _aniosEnPlataforma(DateTime fecha) {
  final dias = DateTime.now().difference(fecha).inDays;
  if (dias < 30) return 'se unió hace poco';
  if (dias < 365) return '${(dias / 30).floor()} meses en la plataforma';
  final anios = (dias / 365).floor();
  return '$anios ${anios == 1 ? 'año' : 'años'} en la plataforma';
}

class PerfilScreen extends StatefulWidget {
  final bool showBack;
  const PerfilScreen({super.key, this.showBack = false});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _telefonoCtrl;
  String? _selfie;
  bool _init = false;
  bool _subiendoFoto = false;

  Future<void> _cambiarFoto() async {
    setState(() => _subiendoFoto = true);
    try {
      final url = await pickAndUploadImage(carpeta: 'selfies');
      if (url != null) setState(() => _selfie = url);
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final yo = app.usuario!;
    if (!_init) {
      _nombreCtrl = TextEditingController(text: yo.nombre);
      _telefonoCtrl = TextEditingController(text: yo.telefono);
      _selfie = yo.selfie;
      _init = true;
    }
    final rating = yo.tipo != TipoUsuario.admin ? avgRating(app.historial, usuarioId: yo.id, tipo: yo.tipo) : null;

    return Screen(
      title: 'Mi Perfil',
      subtitle: 'NexCarg — ${yo.subtipo}',
      onBack: widget.showBack ? () => Navigator.of(context).pop() : null,
      children: [
        AppCard(
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Column(children: [
            InkWell(
              onTap: _cambiarFoto,
              borderRadius: BorderRadius.circular(42),
              child: Container(
                width: 84, height: 84,
                decoration: BoxDecoration(color: AppColors.gris100, shape: BoxShape.circle, border: Border.all(color: AppColors.amber, width: 3)),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: _subiendoFoto
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : (_selfie != null ? AppImage(path: _selfie!, width: 84, height: 84) : Icon(tipoIcon[yo.tipo], size: 40, color: AppColors.navy)),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _cambiarFoto,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(color: AppColors.gris100, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.camera_alt, size: 13, color: AppColors.navy),
                  const SizedBox(width: 5),
                  Text('Cambiar foto', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navy)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AppBadge(tone: yo.verificado ? 'verificado' : 'sinVerificar', label: yo.verificado ? 'Cuenta verificada' : 'Cuenta en verificación'),
                if (rating != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                    decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Stars(value: rating),
                  ),
                ],
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Miembro desde ${yo.fechaRegistro.year} · ${_aniosEnPlataforma(yo.fechaRegistro)}',
                style: TextStyle(fontSize: 11.5, color: AppColors.grisM),
              ),
            ),
            if (!yo.verificado)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text(
                  'Tu cuenta está en revisión. Un administrador va a validar tus documentos antes de habilitar todas las funciones.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.amberText, height: 1.4),
                ),
              ),
          ]),
        ),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AppTextField(label: 'Nombre / Empresa', controller: _nombreCtrl),
            AppTextField(label: 'Correo electrónico', controller: TextEditingController(text: yo.email), enabled: false),
            AppTextField(label: 'Teléfono', placeholder: '+(504) 9xxx-xxxx', controller: _telefonoCtrl),
            AppTextField(label: 'Tipo de cuenta', controller: TextEditingController(text: yo.subtipo), enabled: false),
            if (yo.tipo == TipoUsuario.transportista) ...[
              AppTextField(label: 'Vehículo', controller: TextEditingController(text: yo.vehiculo ?? ''), enabled: false),
              AppTextField(label: 'Capacidad', controller: TextEditingController(text: yo.capacidad != null ? '${yo.capacidad} ton' : ''), enabled: false),
              AppTextField(label: 'Placa', controller: TextEditingController(text: yo.placa ?? ''), enabled: false),
            ],
            AppButton(
              title: 'Guardar cambios', fullWidth: true,
              onPressed: () async {
                await app.actualizarPerfil(yo.id, nombre: _nombreCtrl.text, telefono: _telefonoCtrl.text, selfie: _selfie);
                if (context.mounted) app.showToast('Perfil actualizado');
              },
            ),
          ]),
        ),
        AppButton(
          title: 'Cerrar sesión', variant: AppButtonVariant.outline, fullWidth: true,
          icon: Icon(Icons.logout, size: 16, color: AppColors.navy),
          onPressed: () => app.logout(),
        ),
      ],
    );
  }
}
