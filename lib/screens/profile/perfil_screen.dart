import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/constants.dart';
import '../../models/models.dart';
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

  Future<void> _cambiarFoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _selfie = file.path);
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
                child: _selfie != null ? AppImage(path: _selfie!, width: 84, height: 84) : Icon(tipoIcon[yo.tipo], size: 40, color: AppColors.navy),
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
                  const Icon(Icons.camera_alt, size: 13, color: AppColors.navy),
                  const SizedBox(width: 5),
                  const Text('Cambiar foto', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navy)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AppBadge(tone: yo.verificado ? 'verificado' : 'sinVerificar', label: yo.verificado ? 'Cuenta verificada' : 'Sin verificar'),
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
              onPressed: () {
                app.actualizarPerfil(yo.id, nombre: _nombreCtrl.text, telefono: _telefonoCtrl.text, selfie: _selfie);
                app.showToast('Perfil actualizado');
              },
            ),
          ]),
        ),
        AppButton(
          title: 'Cerrar sesión', variant: AppButtonVariant.outline, fullWidth: true,
          icon: const Icon(Icons.logout, size: 16, color: AppColors.navy),
          onPressed: app.logout,
        ),
      ],
    );
  }
}
