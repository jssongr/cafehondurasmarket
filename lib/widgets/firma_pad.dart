import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../theme/theme.dart';

/// Captura una firma trazada con el dedo o el mouse.
///
/// Se controla desde afuera con un [FirmaPadController]: el padre pregunta si
/// hay algo dibujado y pide el PNG cuando lo necesita.
class FirmaPadController {
  _FirmaPadState? _state;

  bool get tieneFirma => _state?._trazos.isNotEmpty ?? false;

  void limpiar() => _state?._limpiar();

  /// Devuelve la firma como PNG, o null si no se dibujó nada.
  Future<Uint8List?> exportarPng() => _state?._exportarPng() ?? Future.value(null);
}

class FirmaPad extends StatefulWidget {
  final FirmaPadController controller;
  final double alto;
  final VoidCallback? onCambio;

  const FirmaPad({super.key, required this.controller, this.alto = 180, this.onCambio});

  @override
  State<FirmaPad> createState() => _FirmaPadState();
}

class _FirmaPadState extends State<FirmaPad> {
  /// Cada trazo es una lista de puntos; un trazo nuevo empieza en cada toque.
  final List<List<Offset>> _trazos = [];
  final _claveLienzo = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    super.dispose();
  }

  void _limpiar() {
    setState(_trazos.clear);
    widget.onCambio?.call();
  }

  Future<Uint8List?> _exportarPng() async {
    if (_trazos.isEmpty) return null;
    final obj = _claveLienzo.currentContext?.findRenderObject();
    if (obj is! RenderRepaintBoundary) return null;
    // 3x para que la firma se lea bien al ampliarla en un reclamo.
    final imagen = await obj.toImage(pixelRatio: 3);
    final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
    return datos?.buffer.asUint8List();
  }

  void _empezar(Offset p) {
    setState(() => _trazos.add([p]));
    widget.onCambio?.call();
  }

  void _continuar(Offset p) => setState(() => _trazos.last.add(p));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RepaintBoundary(
          key: _claveLienzo,
          child: Container(
            height: widget.alto,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.gris100, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (_trazos.isEmpty)
                  Center(
                    child: Text('Firmá acá con el dedo', style: TextStyle(fontSize: 12.5, color: AppColors.grisM)),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) => _empezar(d.localPosition),
                  onPanUpdate: (d) => _continuar(d.localPosition),
                  child: CustomPaint(painter: _FirmaPainter(_trazos), size: Size.infinite),
                ),
              ],
            ),
          ),
        ),
        if (_trazos.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _limpiar,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Borrar y firmar de nuevo', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }
}

class _FirmaPainter extends CustomPainter {
  final List<List<Offset>> trazos;
  const _FirmaPainter(this.trazos);

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = AppColors.navy
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final trazo in trazos) {
      if (trazo.length == 1) {
        // Un toque sin arrastrar igual deja marca.
        canvas.drawPoints(ui.PointMode.points, trazo, pincel);
        continue;
      }
      final ruta = Path()..moveTo(trazo.first.dx, trazo.first.dy);
      for (final p in trazo.skip(1)) {
        ruta.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(ruta, pincel);
    }
  }

  @override
  bool shouldRepaint(_FirmaPainter old) => true;
}
