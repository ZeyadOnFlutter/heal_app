import 'dart:io';
import 'package:flutter/material.dart';

class LocalOrNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? placeholder;

  const LocalOrNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  bool get _isRemoteUrl {
    final normalized = imageUrl.toLowerCase();
    return normalized.startsWith('http://') || normalized.startsWith('https://');
  }

  bool get _hasLocalFile => imageUrl.isNotEmpty && File(imageUrl).existsSync();

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    if (_isRemoteUrl) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder ?? const SizedBox.shrink(),
      );
    }

    if (_hasLocalFile) {
      return Image.file(
        File(imageUrl),
        height: height,
        width: width,
        fit: fit,
      );
    }

    return placeholder ?? const SizedBox.shrink();
  }
}
