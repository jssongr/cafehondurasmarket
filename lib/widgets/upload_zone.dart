import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/storage_service.dart';
import '../theme/theme.dart';
import 'app_image.dart';

class UploadZone extends StatefulWidget {
  final IconData icon;
  final String title;
  final String uploadedTitle;
  final String sub;
  final String? image;
  final String carpeta;
  final ValueChanged<String> onPicked;
  final bool scanning;
  final bool done;
  final String doneLabel;
  final String scanningLabel;

  const UploadZone({
    super.key,
    required this.icon,
    required this.title,
    required this.uploadedTitle,
    required this.sub,
    required this.image,
    required this.carpeta,
    required this.onPicked,
    required this.scanning,
    required this.done,
    required this.doneLabel,
    required this.scanningLabel,
  });

  @override
  State<UploadZone> createState() => _UploadZoneState();
}

class _UploadZoneState extends State<UploadZone> {
  bool _subiendo = false;
  String? _error;

  Future<void> _pick() async {
    setState(() { _subiendo = true; _error = null; });
    try {
      final url = await pickAndUploadImage(carpeta: widget.carpeta);
      if (url != null) widget.onPicked(url);
    } catch (e) {
      if (mounted) setState(() => _error = 'No se pudo subir el archivo: ${_detalle(e)}');
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  String _detalle(Object e) {
    if (e is StorageException) return e.message;
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _subiendo ? null : _pick,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gris100, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: AppColors.gris50,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                if (_subiendo)
                  const SizedBox(height: 34, width: 34, child: CircularProgressIndicator(strokeWidth: 2))
                else if (widget.image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: AppImage(path: widget.image!, width: double.infinity, height: 140, fit: BoxFit.cover),
                    ),
                  )
                else
                  Icon(widget.icon, size: 34, color: AppColors.grisM),
                const SizedBox(height: 8),
                Text(
                  _subiendo ? 'Subiendo…' : (widget.image != null ? widget.uploadedTitle : widget.title),
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy),
                ),
                const SizedBox(height: 2),
                Text(widget.sub, style: TextStyle(fontSize: 11, color: AppColors.grisM)),
              ],
            ),
          ),
        ),
        if (widget.scanning)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.azul)),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.scanningLabel, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.azul))),
              ],
            ),
          ),
        if (widget.done)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.verdeBg, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.verde),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.doneLabel, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.verde))),
              ],
            ),
          ),
        if (_error != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.rojoBg, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.rojo),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.rojo))),
              ],
            ),
          ),
      ],
    );
  }
}
