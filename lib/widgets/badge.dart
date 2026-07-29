import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppBadge extends StatelessWidget {
  final String tone;
  final String? label;

  const AppBadge({super.key, required this.tone, this.label});

  @override
  Widget build(BuildContext context) {
    final c = badgeColors[tone] ?? badgeColors['publicada']!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(
        label ?? badgeLabels[tone] ?? tone,
        style: TextStyle(color: c.fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
