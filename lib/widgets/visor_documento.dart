import 'package:flutter/material.dart';
import 'app_image.dart';

/// Muestra un documento a pantalla completa, con zoom. Sin esto, revisar un DNI
/// desde una miniatura es adivinar.
class VisorDocumento extends StatelessWidget {
  final String url;
  final String titulo;

  const VisorDocumento({super.key, required this.url, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: AppImage(path: url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

Future<void> abrirDocumento(BuildContext context, String url, String titulo) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(builder: (_) => VisorDocumento(url: url, titulo: titulo)),
  );
}
