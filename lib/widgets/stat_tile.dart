import 'package:flutter/material.dart';
import '../theme/theme.dart';

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  /// Nulo = ámbar. No puede ser el valor por omisión directamente porque los
  /// colores ahora dependen del tema y ya no son constantes.
  final Color? accent;

  const StatTile({super.key, required this.label, required this.value, this.sub, required this.icon, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.amber;
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minWidth: 150),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.grisM, letterSpacing: 0.4),
                  ),
                ),
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 14, color: color),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.navy)),
            if (sub != null) Text(sub!, style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
          ],
        ),
      ),
    );
  }
}
