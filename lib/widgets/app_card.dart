import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const AppCard({super.key, required this.child, this.padding, this.crossAxisAlignment = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: cardShadow,
      ),
      child: child,
    );
  }
}
