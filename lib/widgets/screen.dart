import 'package:flutter/material.dart';
import '../theme/theme.dart';

class Screen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? right;
  final List<Widget> children;
  final VoidCallback? onBack;

  const Screen({
    super.key,
    this.title,
    this.subtitle,
    this.right,
    required this.children,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onBack != null) ...[
                      InkWell(
                        onTap: onBack,
                        borderRadius: BorderRadius.circular(17),
                        child: Container(
                          width: 34, height: 34,
                          decoration: const BoxDecoration(color: AppColors.gris50, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Icon(Icons.chevron_left, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: -0.4)),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(subtitle!, style: const TextStyle(fontSize: 12.5, color: AppColors.grisM)),
                            ),
                        ],
                      ),
                    ),
                    if (right != null) right!,
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl * 2),
                children: [
                  for (final c in children) Padding(padding: const EdgeInsets.only(bottom: AppSpacing.lg), child: c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
