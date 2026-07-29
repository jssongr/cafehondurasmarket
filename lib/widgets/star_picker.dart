import 'package:flutter/material.dart';
import '../theme/theme.dart';

class StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarPicker({super.key, required this.value, required this.onChanged, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final n = i + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onChanged(n),
              child: Icon(n <= value ? Icons.star : Icons.star_border, size: size, color: AppColors.amber),
            ),
          );
        }),
      ),
    );
  }
}
