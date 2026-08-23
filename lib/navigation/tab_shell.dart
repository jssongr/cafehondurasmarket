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
                gradient: degradadoSuperficie,
                border: Border(top: BorderSide(color: AppColors.gris100)),
                // La sombra apunta hacia arriba: la barra flota por encima del
                // contenido que pasa por debajo al desplazarse.
                boxShadow: [
                  BoxShadow(
                    color: AppColors.marcaFondo.withValues(alpha: 0.10),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.destinations.length; i++)
                        Expanded(child: _Pestana(
                          destino: widget.destinations[i],
                          activa: i == _controller.index,
                          onTap: () => _controller.goTo(i),
                        )),
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

/// Una pestaña de la barra inferior. La activa se marca con una pastilla de
/// color detrás del icono, no solo cambiándole el tono: en una pantalla llena
/// de color, un icono azul entre iconos grises no salta lo suficiente.
class _Pestana extends StatelessWidget {
  final TabDestination destino;
  final bool activa;
  final VoidCallback onTap;

  const _Pestana({required this.destino, required this.activa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = activa ? AppColors.blue : AppColors.grisM;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: activa ? AppColors.blue.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Icon(activa ? destino.activeIcon : destino.icon, size: 21, color: color),
              ),
              if ((destino.badge ?? 0) > 0)
                Positioned(
                  top: -3,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                    child: Text('${destino.badge}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            destino.label,
            style: TextStyle(fontSize: 10.5, fontWeight: activa ? FontWeight.w800 : FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
