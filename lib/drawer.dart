import 'package:flutter/material.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';
import 'package:image_picker/image_picker.dart';

class PuzzleDrawer extends StatefulWidget {
  const PuzzleDrawer({Key? key, required this.settings}) : super(key: key);

  final Settings settings;
  @override
  _PuzzleDrawerState createState() => _PuzzleDrawerState();
}

class _PuzzleDrawerState extends State<PuzzleDrawer> {
  @override
  initState() {
    super.initState();

    widget.settings.addListener(_onSettingsUpdate);
  }

  @override
  dispose() {
    widget.settings.removeListener(_onSettingsUpdate);

    super.dispose();
  }

  _onSettingsUpdate() {
    setState(() {});
  }

  _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      XFile? imageFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1440,
        maxHeight: 1440,
      );

      setState(() {
        assert(imageFile != null);
        widget.settings.setImageFile(imageFile!);
      });
    } catch (e) {
      setState(() {
        widget.settings.setImageFile(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Puzzle Settings'),
          ),
          ListTile(
            title: const Text('Select Photo'),
            trailing: ImageFromSource(
              width: 50,
              settings: widget.settings,
            ),
            onTap: () {
              _pickImage();
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Move Speed'),
                Expanded(
                  child: Slider.adaptive(
                    value: 3 - widget.settings.moveSpeed.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    onChanged: (newValue) {
                      widget.settings.moveSpeed = 3 - newValue.toInt();
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Play Sounds'),
            trailing: Checkbox(
              value: widget.settings.isPlayingSounds,
              onChanged: (newValue) {
                widget.settings.isPlayingSounds = !widget.settings.isPlayingSounds;
              },
            ),
          ),
          ListTile(
            title: const Text('Teaching Mode'),
            trailing: Checkbox(
              value: widget.settings.isTeachingMode,
              onChanged: (newValue) {
                widget.settings.isTeachingMode = !widget.settings.isTeachingMode;
              },
            ),
          ),
          ListTile(
            title: const Text('Slide Mode'),
            trailing: Checkbox(
              value: widget.settings.isSliding,
              onChanged: (newValue) {
                widget.settings.isSliding = !widget.settings.isSliding;
              },
            ),
          ),
          ListTile(
            title: const Text('Show Status'),
            trailing: Checkbox(
              value: widget.settings.isShowingStatus,
              onChanged: (newValue) {
                widget.settings.isShowingStatus = !widget.settings.isShowingStatus;
              },
            ),
          ),
          ListTile(
            title: const Text('Reset Settings'),
            onTap: () {
              widget.settings.resetSettings();
            },
          ),
        ],
      ),
    );
  }
}
