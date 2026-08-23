import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// La pieza visual de la portada: un viaje en curso, como se ve dentro de la
/// app.
///
/// La portada era puro texto con medio lado vacío, y eso obliga a quien llega a
/// imaginarse qué es NexCarg. Mostrar el producto —una ruta con su avance, el
/// pago retenido, la prueba de entrega— explica en un vistazo lo que tres
/// párrafos no alcanzan a explicar.
///
/// Está dibujado con widgets y no es una captura de pantalla: se ve nítido en
/// cualquier tamaño, no engorda la descarga, y no queda desactualizado cuando la
/// app cambie de aspecto.
class ViajeVivo extends StatelessWidget {
  final bool amplio;
  const ViajeVivo({super.key, required this.amplio});

  static const _paradas = [
    ('Ciudad de Panamá', 'Recogida · lun 14:20', _Estado.hecho),
    ('San José, Costa Rica', 'Cruce de frontera · mar 08:05', _Estado.hecho),
    ('Managua, Nicaragua', 'En ruta ahora', _Estado.actual),
    ('San Pedro Sula, Honduras', 'Estimado · jue 11:00', _Estado.pendiente),
    ('Ciudad de Guatemala', 'Entrega · vie 16:30', _Estado.pendiente),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(amplio ? 22 : 18),
      decoration: BoxDecoration(
        // Vidrio sobre el degradado del fondo, no un panel opaco: así la pieza
        // se siente apoyada sobre la portada en vez de pegada encima.
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), offset: const Offset(0, 22), blurRadius: 50),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF5C86FF), Color(0xFF0D47FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0D47FF).withValues(alpha: 0.5), blurRadius: 18, offset: const Offset(0, 6)),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_shipping_rounded, size: 19, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Carga refrigerada · 18 t',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Contrato firmado por ambas partes',
                  style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.6))),
            ]),
          ),
          const _PastillaVivo(),
        ]),
        const SizedBox(height: 18),
        for (var i = 0; i < _paradas.length; i++)
          _Parada(
            titulo: _paradas[i].$1,
            detalle: _paradas[i].$2,
            estado: _paradas[i].$3,
            ultima: i == _paradas.length - 1,
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(children: [
            Icon(Icons.lock_outline_rounded, size: 17, color: AppColors.green),
            const SizedBox(width: 9),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pago retenido en garantía',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Se libera con la prueba de entrega',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.55))),
              ]),
            ),
            const Text('L 84,200',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
        ),
      ]),
    );
  }
}

enum _Estado { hecho, actual, pendiente }

/// Punto verde con halo, como el de "en vivo" de cualquier transmisión. Es la
/// señal más rápida de que lo que se está viendo pasa ahora mismo.
class _PastillaVivo extends StatelessWidget {
  const _PastillaVivo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.green,
            boxShadow: [BoxShadow(color: AppColors.green, blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        Text('En vivo',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.green, letterSpacing: 0.3)),
      ]),
    );
  }
}

class _Parada extends StatelessWidget {
  final String titulo;
  final String detalle;
  final _Estado estado;
  final bool ultima;

  const _Parada({required this.titulo, required this.detalle, required this.estado, required this.ultima});

  @override
  Widget build(BuildContext context) {
    final actual = estado == _Estado.actual;
    final hecho = estado == _Estado.hecho;
    final color = actual ? AppColors.green : (hecho ? Colors.white.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.3));

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Columna del riel: el punto y la línea que baja hasta la siguiente
        // parada. El tramo ya recorrido va sólido; el que falta, apagado.
        SizedBox(
          width: 22,
          child: Column(children: [
            Container(
              width: actual ? 13 : 9,
              height: actual ? 13 : 9,
              margin: EdgeInsets.only(top: actual ? 3 : 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hecho || actual ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
                boxShadow: actual
                    ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 1)]
                    : null,
              ),
            ),
            if (!ultima)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: hecho ? Colors.white.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.12),
                ),
              ),
          ]),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: ultima ? 0 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: actual ? FontWeight.w800 : FontWeight.w600,
                    color: Colors.white.withValues(alpha: estado == _Estado.pendiente ? 0.45 : 1),
                  )),
              const SizedBox(height: 1),
              Text(detalle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: actual ? AppColors.green : Colors.white.withValues(alpha: 0.45),
                    fontWeight: actual ? FontWeight.w700 : FontWeight.w400,
                  )),
            ]),
          ),
        ),
      ]),
    );
  }
}
