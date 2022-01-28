import 'package:flutter/material.dart';
import 'package:flutter_15/settings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';

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
      );

      setState(() {
        final settings = context.read<Settings>();
        settings.imageFile = imageFile;
      });
    } catch (e) {
      setState(() {
        final settings = context.read<Settings>();
        settings.imageFile = null;
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
            trailing: _buildSmallSizeImage(),
            onTap: () {
              _pickImage();
            },
          ),
          ListTile(
            title: Row(
              children: [
                const Text('Solve Speed'),
                Expanded(
                  child: Slider.adaptive(
                    value: settings.speed.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    onChanged: (newValue) {
                      settings.speed = newValue.toInt();
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Play Sounds'),
            trailing: Checkbox(
              value: settings.playSounds,
              onChanged: (newValue) {
                settings.playSounds = !settings.playSounds;
              },
            ),
          ),
          ListTile(
            title: const Text('Teaching Mode'),
            trailing: Checkbox(
              value: settings.teachingMode,
              onChanged: (newValue) {
                settings.teachingMode = !settings.teachingMode;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSizeImage() {
    final settings = context.watch<Settings>();
    if (settings.imageFile != null) {
      return Image.network(
        settings.imageFile!.path,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/family.jpg',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }
}
