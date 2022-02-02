import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';

/// Contains global settings for the app.
///
/// The settings are persisted locally.
class Settings extends ChangeNotifier {
  static const localStorageKey = 'puzzle_15';
  static const imageFileBytesKey = 'imageFileBytes';
  static const imageFilePathKey = 'imageFilePath';
  static const moveSpeedKey = 'speed';
  static const isSlidingKey = 'isSliding';
  static const isTeachingModeKey = 'teachingMode';
  static const isPlayingSoundsKey = 'playSounds';

  Settings() {
    _localStorage.ready.then(
      (isSuccessful) {
        if (isSuccessful) {
          _loadSettings();
        }
      },
    );
  }

  final LocalStorage _localStorage = LocalStorage(localStorageKey);

  /// Whether the local storage is initialized and loaded
  bool _hasLocalStorage = false;

  /// Whether there is a custom picture file
  bool get hasImageFile => _imageFilePath != null || _imageFileBytes != null;

  /// Sets and saves the new image file
  ///
  /// The web can't read a saved file by path, so in that
  /// case the bytes are saved.
  void setImageFile(XFile? file) async {
    if (kIsWeb) {
      _imageFileBytes = await file?.readAsBytes();
      _saveSetting(
        key: imageFileBytesKey,
        value: _imageFileBytes,
      );
    } else {
      _imageFilePath = file?.path;
      _saveSetting(
        key: imageFilePathKey,
        value: _imageFilePath,
      );
    }

    notifyListeners();
  }

  /// The path name for the custom picture (not available for web)
  String? get imageFilePath => _imageFilePath;
  String? _imageFilePath;

  /// The file data for the custom picture (used for web)
  Uint8List? get imageFileBytes => _imageFileBytes;
  Uint8List? _imageFileBytes;

  /// Move animation/Auto solve speed
  ///
  /// Used as a multiplier so 1 is the fastest and larger numbers
  /// are slower.
  int get moveSpeed => _moveSpeed;
  set moveSpeed(int newSpeed) {
    _moveSpeed = newSpeed;
    _saveSetting(
      key: moveSpeedKey,
      value: newSpeed,
    );
    notifyListeners();
  }

  int _moveSpeed = 2;

  /// Whether sounds should be played
  bool get isPlayingSounds => _isPlayingSounds;
  set isPlayingSounds(bool newPlaySounds) {
    _isPlayingSounds = newPlaySounds;
    _saveSetting(
      key: isPlayingSoundsKey,
      value: newPlaySounds,
    );
    notifyListeners();
  }

  bool _isPlayingSounds = true;

  /// Whether teaching mode is set for auto solve
  bool get isTeachingMode => _isTeachingMode;
  set isTeachingMode(bool newTeachingMode) {
    _isTeachingMode = newTeachingMode;
    _saveSetting(
      key: isTeachingModeKey,
      value: newTeachingMode,
    );
    notifyListeners();
  }

  bool _isTeachingMode = false;

  /// Whether moves are made by sliding (vs tapping)
  bool get isSliding => _isSliding;
  set isSliding(bool newTeachingMode) {
    _isSliding = newTeachingMode;
    _saveSetting(
      key: isSlidingKey,
      value: _isSliding,
    );
    notifyListeners();
  }

  bool _isSliding = false;

  /// Resets all settings to defaults.
  Future<void> resetSettings() async {
    await _localStorage.clear();

    _loadSettings();
  }

  /// Loads all settings with defaults upon app start.
  void _loadSettings() {
    _isPlayingSounds = _localStorage.getItem(isPlayingSoundsKey) ?? true;
    _isTeachingMode = _localStorage.getItem(isTeachingModeKey) ?? false;
    _isSliding = _localStorage.getItem(isSlidingKey) ?? false;
    _moveSpeed = _localStorage.getItem(moveSpeedKey) ?? 2;

    _imageFilePath = _localStorage.getItem(imageFilePathKey);

    // Local storage stores the bytes as List<dynamic> which
    // then need to be converted to Uint8List.
    final List<dynamic>? dynamicImageBytes = _localStorage.getItem(imageFileBytesKey);
    if (dynamicImageBytes != null) {
      _imageFileBytes = Uint8List.fromList(dynamicImageBytes.map((e) => e as int).toList());
    }

    _hasLocalStorage = true;

    notifyListeners();
  }

  /// Saves an individual setting.
  void _saveSetting({required String key, required dynamic value}) {
    if (!_hasLocalStorage) {
      return;
    }

    try {
      _localStorage.setItem(key, value);
    } catch (error) {
      // The file could be too large. If this fails
      // for any reason, we don't want to ruin the
      // run of the app.  So in this case, we will
      // ignore any errors.
    }
  }
}
