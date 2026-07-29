import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'app_image.dart';

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
      decoration: BoxDecoration(color: AppColors.gris100, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: uri != null && uri!.isNotEmpty
          ? AppImage(path: uri!, width: size, height: size, fit: BoxFit.cover)
          : Icon(tipoIcon[tipo], size: size * 0.48, color: AppColors.navy),
    );
  }
}
