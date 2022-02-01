import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings.dart';

//TODO: Dartdoc
class ImageFromSource extends StatelessWidget {
  const ImageFromSource({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

    if (settings.hasImageFile) {
      if (kIsWeb) {
        // TODO: use bytes vs network
        return Image.network(
          settings.imageFilePath!,
          width: width,
          height: width,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          File(settings.imageFilePath!),
          width: width,
          height: width,
          fit: BoxFit.cover,
        );
      }
    }

    // Give a default image if there is not a custom image
    return Image.asset(
      'assets/family.jpg',
      width: width,
      height: width,
      fit: BoxFit.cover,
    );
  }
}
