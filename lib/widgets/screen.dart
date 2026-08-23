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
      // Un fondo de un solo color plano es lo que hace que una app se vea
      // barata. Este tiñe apenas la parte de arriba con el azul de marca, de
      // modo que la pantalla tiene aire arriba y peso abajo.
      decoration: BoxDecoration(
        color: AppColors.bg,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.42],
          colors: [
            Color.alphaBlend(AppColors.blue.withValues(alpha: 0.055), AppColors.bg),
            AppColors.bg,
          ],
        ),
      ),
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
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: degradadoSuperficie,
                            shape: BoxShape.circle,
                            border: bordeSuperficie,
                            boxShadow: sombraApoyo,
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.chevron_left, color: AppColors.navy),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title!, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.navy, letterSpacing: -0.4)),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(subtitle!, style: TextStyle(fontSize: 12.5, color: AppColors.grisM)),
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
