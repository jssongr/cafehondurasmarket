import 'dart:math';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _uploadsBucket = 'uploads';

/// Cuánto vale un enlace firmado. Una hora alcanza de sobra para revisar la
/// ficha de un usuario sin tener que pedir enlaces nuevos a cada rato.
const _duracionFirma = Duration(hours: 1);

/// Se vuelve a firmar un poco antes de que venza, para que a nadie se le corte
/// una imagen que ya tenía en pantalla.
const _margenRefirma = Duration(minutes: 5);

final Map<String, ({String url, DateTime vence})> _firmadas = {};

/// Lo que se acaba de subir en esta sesión, tal cual quedó en memoria. Durante
/// el registro todavía no hay sesión con la cual firmar nada, así que sin esto
/// la vista previa del documento recién subido saldría rota justo cuando la
/// persona necesita comprobar que la foto se ve bien.
final Map<String, Uint8List> _recienSubidas = {};
const _maxRecienSubidas = 12;

/// Bytes del archivo recién subido, si todavía están en memoria.
Uint8List? bytesRecienSubidos(String url) => _recienSubidas[url];

/// La ruta dentro del depósito, o null si la URL no es de nuestro
/// almacenamiento (un enlace externo, o uno que ya viene firmado).
String? _rutaEnDeposito(String url) {
  const marca = '/storage/v1/object/public/$_uploadsBucket/';
  final i = url.indexOf(marca);
  if (i == -1) return null;
  final ruta = url.substring(i + marca.length).split('?').first;
  return ruta.isEmpty ? null : Uri.decodeComponent(ruta);
}

/// Convierte la URL guardada en la base de datos en un enlace que de verdad
/// abre. El depósito es privado: la URL guardada es solo la dirección del
/// archivo, y hay que pedirle a Supabase un permiso temporal para leerlo.
///
/// Lo que no sea de nuestro almacenamiento se devuelve igual, para no romper
/// enlaces externos.
Future<String> urlFirmada(String urlGuardada) async {
  final ruta = _rutaEnDeposito(urlGuardada);
  if (ruta == null) return urlGuardada;

  final enCache = _firmadas[ruta];
  if (enCache != null && enCache.vence.isAfter(DateTime.now())) return enCache.url;

  try {
    final url = await Supabase.instance.client.storage
        .from(_uploadsBucket)
        .createSignedUrl(ruta, _duracionFirma.inSeconds);
    _firmadas[ruta] = (url: url, vence: DateTime.now().add(_duracionFirma - _margenRefirma));
    return url;
  } catch (_) {
    // Si firmar falla —no hay sesión, o los permisos del depósito todavía no
    // están puestos— se devuelve la dirección tal cual. Mientras el depósito
    // siga siendo público la imagen se ve igual, y así el cambio se puede
    // desplegar antes de tocar la base de datos sin dejar la app en blanco.
    return urlGuardada;
  }
}

/// Al cerrar sesión hay que soltar los enlaces firmados: son permisos de la
/// persona que estaba usando la app, no de la siguiente.
void olvidarEnlacesFirmados() {
  _firmadas.clear();
  _recienSubidas.clear();
}

/// Opens the image picker, uploads the chosen image to Supabase Storage,
/// and returns its public URL — or null if the user cancelled.
Future<String?> pickAndUploadImage({required String carpeta}) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
  if (file == null) return null;
  return uploadImageBytes(await file.readAsBytes(), carpeta: carpeta, filename: file.name);
}

final _random = Random();

/// 8 random hex characters. Built one nibble at a time on purpose: `1 << 32`
/// evaluates to 0 on the web, and Random.nextInt(0) throws a RangeError.
String _sufijoAleatorio() => List.generate(8, (_) => _random.nextInt(16).toRadixString(16)).join();

Future<String> uploadImageBytes(Uint8List bytes, {required String carpeta, required String filename}) async {
  final ext = filename.contains('.') ? filename.split('.').last : 'jpg';
  final path = '$carpeta/${DateTime.now().millisecondsSinceEpoch}_${_sufijoAleatorio()}.$ext';
  final sb = Supabase.instance.client;
  // No upsert: the path is already unique, and upsert would additionally require an
  // UPDATE storage policy, which anonymous users (mid-registration) don't have.
  await sb.storage.from(_uploadsBucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: _contentType(ext)));
  // Se sigue guardando la URL con forma pública: es la dirección estable del
  // archivo y de ahí sale la ruta para firmarlo. Sola no abre nada.
  final url = sb.storage.from(_uploadsBucket).getPublicUrl(path);
  if (_recienSubidas.length >= _maxRecienSubidas) {
    _recienSubidas.remove(_recienSubidas.keys.first);
  }
  _recienSubidas[url] = bytes;
  return url;
}

String _contentType(String ext) {
  switch (ext.toLowerCase()) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    case 'gif':
      return 'image/gif';
    default:
      return 'image/jpeg';
  }
}
