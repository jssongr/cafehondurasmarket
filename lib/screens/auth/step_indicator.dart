import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int current;

  const StepIndicator({super.key, required this.steps, required this.current});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < steps.length; i++) {
      final n = i + 1;
      final done = current > n;
      final active = current == n;
      children.add(Column(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: done ? AppColors.navy : (active ? AppColors.amber : AppColors.gris100),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text('$n', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.grisM)),
          ),
          const SizedBox(height: 4),
          Text(steps[i], style: TextStyle(fontSize: 11, color: active ? AppColors.navy : AppColors.grisM, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ],
      ));
      if (i < steps.length - 1) {
        children.add(Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: current > n ? AppColors.navy : AppColors.gris100,
          ),
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
