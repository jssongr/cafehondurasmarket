import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Superficie elevada: la pieza de la que están hechas casi todas las pantallas.
///
/// Junta las cuatro cosas que hacen que algo se lea como un objeto y no como un
/// rectángulo de color: un degradado muy leve de arriba abajo, un borde fino que
/// se aclara en el canto superior, una sombra de dos capas y las esquinas
/// redondeadas. Por separado ninguna se nota; juntas es la diferencia entre una
/// pantalla plana y una que parece tener relieve.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radio;

  /// Cuánto se despega de la superficie. 0 = apoyado, 1 = tarjeta, 2 = flotante.
  final int elevacion;

  /// Franja de color en el borde izquierdo. Se usa para marcar el estado de una
  /// tarjeta sin tener que meterle una etiqueta más.
  final Color? filo;

  final VoidCallback? onTap;
  final Color? fondo;

  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radio = AppRadius.lg,
    this.elevacion = 1,
    this.filo,
    this.onTap,
    this.fondo,
  });

  @override
  Widget build(BuildContext context) {
    final sombra = switch (elevacion) {
      0 => sombraApoyo,
      2 => floatingShadow,
      _ => cardShadow,
    };

    Widget contenido = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fondo,
        gradient: fondo == null ? degradadoSuperficie : null,
        borderRadius: BorderRadius.circular(radio),
        border: bordeSuperficie,
        boxShadow: sombra,
      ),
      child: child,
    );

    if (filo != null) {
      contenido = Stack(fit: StackFit.passthrough, children: [
        contenido,
        // Va por encima y recortado al mismo radio, para que la franja siga la
        // curva de la esquina en vez de asomar por fuera.
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radio),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [filo!, filo!.withValues(alpha: 0.55)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]);
    }

    if (onTap == null) return contenido;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radio),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radio), child: contenido),
    );
  }
}

/// Cuadrito de icono con degradado y resplandor propio. Aparece en las tarjetas
/// de datos, en los pasos y en los menús; tenerlo en un solo lugar evita que
/// cada pantalla invente el suyo.
class IconoRelieve extends StatelessWidget {
  final IconData icono;
  final Color color;
  final double tamano;

  const IconoRelieve({super.key, required this.icono, required this.color, this.tamano = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tamano * 0.32),
        gradient: LinearGradient(
          colors: [Color.lerp(color, Colors.white, 0.28)!, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: resplandor(color, fuerza: 0.34),
      ),
      alignment: Alignment.center,
      child: Icon(icono, size: tamano * 0.5, color: Colors.white),
    );
  }
}
