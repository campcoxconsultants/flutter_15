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
  double foo = 2;
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
                      value: foo,
                      min: 1,
                      max: 3,
                      divisions: 2,
                      onChanged: (newValue) {
                        setState(() {
                          foo = newValue;
                          print('foo $foo');
                        });
                      }),
                ),
              ],
            ),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
