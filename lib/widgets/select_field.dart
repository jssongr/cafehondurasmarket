import 'package:flutter/material.dart';
import '../theme/theme.dart';

class SelectField extends StatelessWidget {
  final String? label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String placeholder;

  const SelectField({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Selecciona…',
  });

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: const BoxConstraints(maxHeight: 460),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: AppColors.gris300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              label ?? 'Selecciona una opción',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy, letterSpacing: 0.4),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options.map((o) {
                  final selected = o == value;
                  return InkWell(
                    onTap: () {
                      onChanged(o);
                      Navigator.pop(ctx);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              o,
                              style: TextStyle(
                                fontSize: 15,
                                color: selected ? AppColors.navy : AppColors.texto,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (selected) Icon(Icons.check, size: 18, color: AppColors.navy),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(label!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 0.4)),
            ),
          InkWell(
            onTap: () => _open(context),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gris100, width: 1.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: AppColors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? placeholder : value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.5, color: value.isEmpty ? AppColors.grisM : AppColors.texto),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.grisM),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
