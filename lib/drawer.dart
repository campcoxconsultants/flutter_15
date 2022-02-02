import 'package:flutter/material.dart';
import 'package:flutter_15/image.dart';
import 'package:flutter_15/settings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PuzzleDrawer extends StatefulWidget {
  const PuzzleDrawer({Key? key}) : super(key: key);

  @override
  _PuzzleDrawerState createState() => _PuzzleDrawerState();
}

class _PuzzleDrawerState extends State<PuzzleDrawer> {
  bool bar = true;
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
        final settings = context.read<Settings>();
        assert(imageFile != null);
        settings.setImageFile(imageFile!);
      });
    } catch (e) {
      setState(() {
        final settings = context.read<Settings>();
        settings.setImageFile(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

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
            trailing: const ImageFromSource(
              width: 50,
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
                    value: 3 - settings.moveSpeed.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    onChanged: (newValue) {
                      settings.moveSpeed = 3 - newValue.toInt();
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Play Sounds'),
            trailing: Checkbox(
              value: settings.isPlayingSounds,
              onChanged: (newValue) {
                settings.isPlayingSounds = !settings.isPlayingSounds;
              },
            ),
          ),
          ListTile(
            title: const Text('Teaching Mode'),
            trailing: Checkbox(
              value: settings.isTeachingMode,
              onChanged: (newValue) {
                settings.isTeachingMode = !settings.isTeachingMode;
              },
            ),
          ),
          ListTile(
            title: const Text('Slide Mode'),
            trailing: Checkbox(
              value: settings.isSliding,
              onChanged: (newValue) {
                settings.isSliding = !settings.isSliding;
              },
            ),
          ),
          ListTile(
            title: const Text('Reset Settings'),
            onTap: () {
              final settings = context.read<Settings>();

              settings.resetSettings();
            },
          ),
        ],
      ),
    );
  }
}
