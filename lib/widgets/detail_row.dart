import 'package:flutter/material.dart';
import '../theme/theme.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final TextStyle? valueStyle;

  const DetailRow({super.key, required this.label, this.value, this.valueWidget, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gris100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.grisM)),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget ??
                  Text(
                    value ?? '',
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle ?? const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
