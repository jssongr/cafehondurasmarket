import 'package:flutter/material.dart';
import '../theme/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? sub;

  const EmptyState({super.key, required this.icon, required this.title, this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.gris50, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 30, color: AppColors.grisM),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.grisM)),
          ],
        ],
      ),
    );
  }
}
