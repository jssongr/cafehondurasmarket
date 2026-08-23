import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Muestra una imagen guardada en el almacenamiento de Supabase.
///
/// El depósito es privado, así que la dirección guardada en la base de datos no
/// abre por sí sola: hay que cambiarla por un enlace firmado que vale un rato.
/// Todo eso pasa acá adentro para que ninguna pantalla tenga que acordarse.
class AppImage extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({super.key, required this.path, this.width, this.height, this.fit = BoxFit.cover});

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  late Future<String> _url;

  @override
  void initState() {
    super.initState();
    _url = urlFirmada(widget.path);
  }

  @override
  void didUpdateWidget(AppImage anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.path != widget.path) _url = urlFirmada(widget.path);
  }

  Widget _marco({required Widget hijo}) =>
      SizedBox(width: widget.width, height: widget.height, child: hijo);

  Widget _cargando() => _marco(
        hijo: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );

  Widget _rota() => _marco(
        hijo: Container(color: Colors.black12, child: const Icon(Icons.broken_image_outlined)),
      );

  @override
  Widget build(BuildContext context) {
    // Lo que se acaba de subir se dibuja de memoria. Durante el registro no hay
    // sesión todavía y no se puede firmar nada, así que este es el único camino
    // por el que la vista previa del documento se ve.
    final bytes = bytesRecienSubidos(widget.path);
    if (bytes != null) {
      return Image.memory(bytes,
          width: widget.width, height: widget.height, fit: widget.fit,
          errorBuilder: (_, _, _) => _rota());
    }

    return FutureBuilder<String>(
      future: _url,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return _cargando();
        if (snap.hasError || snap.data == null) return _rota();
        return Image.network(
          snap.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, progress) => progress == null ? child : _cargando(),
          errorBuilder: (context, error, stack) => _rota(),
        );
      },
    );
  }
}
