import 'package:flutter/material.dart';
import '../theme/theme.dart';

class Stars extends StatelessWidget {
  final double? value;
  final double size;

  const Stars({super.key, this.value, this.size = 12});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: size, color: AppColors.amber),
        const SizedBox(width: 3),
        Text(value!.toStringAsFixed(1), style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.w700, fontSize: size)),
      ],
    );
  }
}
