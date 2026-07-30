import 'package:flutter/material.dart';
import '../theme/theme.dart';

class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(children: [
        const Icon(Icons.hourglass_top, size: 18, color: AppColors.amberText),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cuenta en verificación', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.amberText)),
            const SizedBox(height: 2),
            const Text('Un administrador está revisando tus documentos. Te avisamos apenas quede aprobada.',
                style: TextStyle(fontSize: 11, color: AppColors.amberText, height: 1.35)),
          ]),
        ),
      ]),
    );
  }
}
