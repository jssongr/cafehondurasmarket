import 'dart:math';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _uploadsBucket = 'uploads';

/// Opens the image picker, uploads the chosen image to Supabase Storage,
/// and returns its public URL — or null if the user cancelled.
Future<String?> pickAndUploadImage({required String carpeta}) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
  if (file == null) return null;
  return uploadImageBytes(await file.readAsBytes(), carpeta: carpeta, filename: file.name);
}

Future<String> uploadImageBytes(Uint8List bytes, {required String carpeta, required String filename}) async {
  final ext = filename.contains('.') ? filename.split('.').last : 'jpg';
  final path = '$carpeta/${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 32)}.$ext';
  final sb = Supabase.instance.client;
  // No upsert: the path is already unique, and upsert would additionally require an
  // UPDATE storage policy, which anonymous users (mid-registration) don't have.
  await sb.storage.from(_uploadsBucket).uploadBinary(path, bytes, fileOptions: FileOptions(contentType: _contentType(ext)));
  return sb.storage.from(_uploadsBucket).getPublicUrl(path);
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
