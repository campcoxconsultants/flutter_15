import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends ChangeNotifier {
  XFile? _imageFile;
  XFile? get imageFile => _imageFile;
  set imageFile(XFile? newImage) {
    _imageFile = newImage;
    notifyListeners();
  }

  int _speed = 2;
  int get speed => _speed;
  set speed(int newSpeed) {
    _speed = newSpeed;
    notifyListeners();
  }

  bool _playSounds = true;
  bool get playSounds => _playSounds;
  set playSounds(bool newPlaySounds) {
    _playSounds = newPlaySounds;
    notifyListeners();
  }

  bool _teachingMode = false;
  bool get teachingMode => _teachingMode;
  set teachingMode(bool newTeachingMode) {
    _teachingMode = newTeachingMode;
    notifyListeners();
  }
}
