import 'package:flutter/material.dart';

// Enum to represent image effects
enum ImageEffect {
  none,
  grayscale,
  sepia,
  invert,
}

//ImageState class to represent image states for menu items
class ImageState {
  final String imagePath;
  final ImageEffect imageEffect;

  ImageState({required this.imagePath, this.imageEffect = ImageEffect.none});
}