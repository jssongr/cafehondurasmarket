import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/root_navigator.dart';
import 'state/app_state.dart';
import 'theme/theme.dart';

void main() {
  runApp(const NexCargApp());
}

class NexCargApp extends StatelessWidget {
  const NexCargApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'NexCarg',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const _RootWithToast(),
      ),
    );
  }
}

class _RootWithToast extends StatelessWidget {
  const _RootWithToast();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        RootNavigator(),
        Positioned(left: 0, right: 0, bottom: 0, child: _ToastOverlay()),
      ],
    );
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final msg = app.toastMsg;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim), child: child),
        ),
        child: msg == null
            ? const SizedBox.shrink(key: ValueKey('empty'))
            : Padding(
                key: ValueKey(app.toastId),
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 28),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: floatingShadow),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle, size: 18, color: Color(0xFF4ADE80)),
                      const SizedBox(width: 10),
                      Flexible(child: Text(msg, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ),
              ),
      ),
    );
  }
}
