import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';

class TabShellController extends ChangeNotifier {
  int index = 0;
  void goTo(int i) {
    index = i;
    notifyListeners();
  }
}

class TabDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;
  final int? badge;

  TabDestination({required this.icon, required this.activeIcon, required this.label, required this.page, this.badge});
}

class TabShell extends StatefulWidget {
  final List<TabDestination> destinations;
  const TabShell({super.key, required this.destinations});

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  final _controller = TabShellController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TabShellController>.value(
      value: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            body: IndexedStack(
              index: _controller.index,
              children: [for (final d in widget.destinations) d.page],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.gris100)),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 62,
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.destinations.length; i++)
                        Expanded(
                          child: InkWell(
                            onTap: () => _controller.goTo(i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      i == _controller.index ? widget.destinations[i].activeIcon : widget.destinations[i].icon,
                                      size: 22,
                                      color: i == _controller.index ? AppColors.blue : AppColors.grisM,
                                    ),
                                    if ((widget.destinations[i].badge ?? 0) > 0)
                                      Positioned(
                                        top: -4, right: -8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                                          child: Text('${widget.destinations[i].badge}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.destinations[i].label,
                                  style: TextStyle(
                                    fontSize: 10.5, fontWeight: FontWeight.w700,
                                    color: i == _controller.index ? AppColors.blue : AppColors.grisM,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
