import 'dart:convert';

import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _placeholder();
    if (imageUrl.startsWith('data:image/')) {
      final separator = imageUrl.indexOf(',');
      if (separator == -1) return _placeholder();
      try {
        return Image.memory(
          base64Decode(imageUrl.substring(separator + 1)),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        );
      } on FormatException {
        return _placeholder();
      }
    }
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: const Color(0xFFF5E9DC),
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Color(0xFFF5E9DC),
    child: Center(
      child: Icon(Icons.restaurant_rounded, size: 42, color: Color(0xFFE87532)),
    ),
  );
}
