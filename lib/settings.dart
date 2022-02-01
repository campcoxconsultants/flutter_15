import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';

class Settings extends ChangeNotifier {
  Settings() {
    _localStorage.ready.then(
      (isSuccessful) {
        if (isSuccessful) {
          _loadSettings();
        }
      },
    );
  }

  final LocalStorage _localStorage = LocalStorage('puzzle_15');
  bool _hasLocalStorage = false;

  // TODO: save bytes if web and filename if other
  /// Whether there is a custom picture file
  bool get hasImageFile => _imageFilePath != null;
  String? _imageFilePath;
  String? get imageFilePath => _imageFilePath;
  set imageFilePath(String? newImage) {
    _imageFilePath = newImage;
    _saveSetting(key: 'imageFilePath', value: newImage);
    notifyListeners();
  }

  int _speed = 2;
  int get speed => _speed;
  set speed(int newSpeed) {
    _speed = newSpeed;
    _saveSetting(key: 'speed', value: newSpeed);
    notifyListeners();
  }

  bool _playSounds = true;
  bool get playSounds => _playSounds;
  set playSounds(bool newPlaySounds) {
    _playSounds = newPlaySounds;
    _saveSetting(key: 'playSounds', value: newPlaySounds);
    notifyListeners();
  }

  bool _teachingMode = false;
  bool get teachingMode => _teachingMode;
  set teachingMode(bool newTeachingMode) {
    _teachingMode = newTeachingMode;
    _saveSetting(key: 'teachingMode', value: newTeachingMode);
    notifyListeners();
  }

  // TODO: slide vs tap
  Future<void> resetSettings() async {
    await _localStorage.clear();

    _loadSettings();
  }

  void _loadSettings() {
    _playSounds = _localStorage.getItem('playSounds') ?? true;
    _teachingMode = _localStorage.getItem('teachingMode') ?? false;
    _speed = _localStorage.getItem('speed') ?? 2;

    if (kIsWeb) {
      _imageFilePath = null;
    } else {
      _imageFilePath = _localStorage.getItem('imageFilePath');
    }

    _hasLocalStorage = true;

    notifyListeners();
  }

  void _saveSetting({required String key, required dynamic value}) {
    if (!_hasLocalStorage) {
      return;
    }

    _localStorage.setItem(key, value);
  }
}
