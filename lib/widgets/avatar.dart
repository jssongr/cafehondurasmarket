import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'app_image.dart';

/// Foto de perfil. El aro claro alrededor la separa de lo que tenga detrás —sin
/// él, una selfie oscura sobre una tarjeta oscura se funde con el fondo— y la
/// sombra corta la levanta de la superficie.
class Avatar extends StatelessWidget {
  final String? uri;
  final TipoUsuario tipo;
  final double size;

  const Avatar({super.key, this.uri, required this.tipo, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.gris50, AppColors.gris100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.white, width: 1.5),
        boxShadow: sombraApoyo,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: uri != null && uri!.isNotEmpty
          ? AppImage(path: uri!, width: size, height: size, fit: BoxFit.cover)
          : Icon(tipoIcon[tipo], size: size * 0.46, color: AppColors.grisM),
    );
  }
}
