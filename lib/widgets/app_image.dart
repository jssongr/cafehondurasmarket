import 'package:flutter/material.dart';

/// Renders an image from a Supabase Storage public URL.
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({super.key, required this.path, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (context, error, stack) => Container(color: Colors.black12, width: width, height: height, child: const Icon(Icons.broken_image_outlined)),
    );
  }
}
