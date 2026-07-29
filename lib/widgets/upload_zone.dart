import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme.dart';
import 'app_image.dart';

class UploadZone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String uploadedTitle;
  final String sub;
  final String? image;
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
    required this.onPicked,
    required this.scanning,
    required this.done,
    required this.doneLabel,
    required this.scanningLabel,
  });

  Future<void> _pick() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _pick,
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
                if (image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: AppImage(path: image!, width: double.infinity, height: 140, fit: BoxFit.cover),
                    ),
                  )
                else
                  Icon(icon, size: 34, color: AppColors.grisM),
                const SizedBox(height: 8),
                Text(image != null ? uploadedTitle : title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.grisM)),
              ],
            ),
          ),
        ),
        if (scanning)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.azul)),
                const SizedBox(width: 8),
                Expanded(child: Text(scanningLabel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.azul))),
              ],
            ),
          ),
        if (done)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: AppColors.verdeBg, borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.verde),
                const SizedBox(width: 8),
                Expanded(child: Text(doneLabel, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.verde))),
              ],
            ),
          ),
      ],
    );
  }
}
