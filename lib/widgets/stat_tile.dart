import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'panel.dart';

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 150),
        child: Panel(
          filo: color,
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg + 4, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        label.toUpperCase(),
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.grisM, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  IconoRelieve(icono: icon, color: color, tamano: 30),
                ],
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: -0.7)),
              if (sub != null) Text(sub!, style: TextStyle(fontSize: 11.5, color: AppColors.grisM)),
            ],
          ),
        ),
      ),
    );
  }
}
