import 'dart:io';
import 'package:flutter/material.dart';
import '../config/asset_config.dart';
import '../utils/logger.dart';

/// Image widget that loads from the external cfg2 folder.
///
/// Drop-in replacement for CfgImage:
///   BEFORE: CfgImage('assets/icons/icon_home.png', width: 48)
///   AFTER:  CfgImage('icons/icon_home.png', width: 48)
///
/// The legacy 'assets/...' prefix is also accepted and stripped automatically.
class CfgImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment; 

  const CfgImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center, 
  });

  @override
  Widget build(BuildContext context) {
    final fullPath = AssetConfig.img(path);

    return Image.file(
      File(fullPath),
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
	  alignment: alignment,
      errorBuilder: (ctx, error, stack) {
        logError('CfgImage', 'Missing image: $fullPath');
        return SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        );
      },
    );
  }
}

/// ImageProvider variant — use where ImageProvider is needed directly.
///
/// Example:
///   DecorationImage(image: cfgImageProvider('backgrounds/lounge.png'))
///   Image(image: cfgImageProvider('logo.png'))
FileImage cfgImageProvider(String relativePath) =>
    FileImage(File(AssetConfig.img(relativePath)));