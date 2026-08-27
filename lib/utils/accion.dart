import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/app_state.dart';

/// Ejecuta algo que puede fallar y se asegura de que la persona se entere.
///
/// El patrón que esto reemplaza —`await app.loQueSea(...)` suelto en un
/// `onPressed`— falla en silencio: si la base rechaza la operación, la
/// excepción se pierde, no aparece ningún mensaje, y la persona se queda
/// creyendo que funcionó. Es peor que un error visible, porque nadie vuelve a
/// intentar algo que cree que ya hizo.
///
/// Devuelve true solo si la acción terminó bien.
///
/// ```dart
/// onPressed: () => ejecutar(
///   context,
///   () => app.actualizarPerfil(...),
///   exito: 'Perfil actualizado',
/// ),
/// ```
Future<bool> ejecutar(
  BuildContext context,
  Future<void> Function() accion, {
  String? exito,
  String fallo = 'No se pudo completar la operación',
}) async {
  final app = context.read<AppState>();
  try {
    await accion();
    if (exito != null && context.mounted) app.showToast(exito);
    return true;
  } catch (e) {
    if (!context.mounted) return false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(fallo),
        content: Text(mensajeDeError(e)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido')),
        ],
      ),
    );
    return false;
  }
}

/// Traduce lo que devuelve Supabase a algo que una persona pueda leer.
///
/// Sin esto, un rechazo de permisos llega como "PostgrestException(message:
/// new row violates row-level security policy...)", que no le dice nada a un
/// transportista y encima suena a que la app está rota.
String mensajeDeError(Object e) {
  if (e is PostgrestException) {
    final m = e.message.toLowerCase();
    if (m.contains('row-level security') || m.contains('permission denied')) {
      return 'Tu cuenta no tiene permiso para hacer esto. Si tus documentos todavía '
          'están en revisión, esperá a que un administrador los apruebe.';
    }
    if (m.contains('duplicate key')) {
      return 'Eso ya existe. Actualizá la pantalla y revisá.';
    }
    return e.message;
  }
  if (e is StorageException) return e.message;
  if (e is AuthException) return e.message;

  final texto = e.toString();
  // Sin conexión, el error llega como una excepción de socket o de cliente y el
  // texto crudo no ayuda a nadie.
  if (texto.contains('SocketException') ||
      texto.contains('ClientException') ||
      texto.contains('Failed host lookup')) {
    return 'No se pudo conectar. Revisá tu conexión a internet e intentá de nuevo.';
  }
  return texto;
}
