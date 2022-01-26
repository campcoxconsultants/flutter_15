import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends ChangeNotifier {
  XFile? _imageFile;
  XFile? get imageFile => _imageFile;
  set imageFile(XFile? newImage) {
    _imageFile = newImage;
    notifyListeners();
  }
}
