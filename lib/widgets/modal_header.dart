import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ModalHeader extends StatelessWidget {
  final String title;
  final Widget? badge;
  final VoidCallback onClose;

  const ModalHeader({super.key, required this.title, this.badge, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) badge!,
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: -0.2)),
              ],
            ),
          ),
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.gris50, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 20, color: AppColors.grisM),
            ),
          ),
        ],
      ),
    );
  }
}
