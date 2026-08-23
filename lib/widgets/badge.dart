import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Etiqueta de estado. El borde teñido del mismo color no es adorno: sobre una
/// tarjeta que ya tiene su propio relieve, un relleno pastel sin contorno se
/// desdibuja y la etiqueta deja de leerse como una pieza aparte.
class AppBadge extends StatelessWidget {
  final String tone;
  final String? label;

  const AppBadge({super.key, required this.tone, this.label});

  @override
  Widget build(BuildContext context) {
    final c = badgeColors[tone] ?? badgeColors['publicada']!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 10),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.fg.withValues(alpha: 0.22)),
      ),
      child: Text(
        label ?? badgeLabels[tone] ?? tone,
        style: TextStyle(color: c.fg, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.1),
      ),
    );
  }
}
