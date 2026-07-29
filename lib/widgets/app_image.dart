import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Renders an image from a picked file path, working on both web (blob/network URL)
/// and native platforms (local file path).
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({super.key, required this.path, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(path, width: width, height: height, fit: fit);
    }
    return Image.file(File(path), width: width, height: height, fit: fit);
  }
}
