import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'settings.dart';

//TODO: Dartdoc
class ImageFromSource extends StatelessWidget {
  const ImageFromSource({
    Key? key,
    required this.width,
    required this.height,
    required this.settings,
  }) : super(key: key);

  final double height;
  final double width;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    if (settings.hasImageFile) {
      if (kIsWeb) {
        assert(settings.imageFileBytes != null);
        return Image.memory(
          settings.imageFileBytes!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      } else {
        assert(settings.imageFilePath != null);
        return Image.file(
          File(settings.imageFilePath!),
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      }
    }

    // Give a default image if there is not a custom image
    return Image.asset(
      'assets/family.jpg',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
