import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/dal/CustomPhrase.dart';

import '../models/Phrase.dart';

class AddPhrase extends StatefulWidget {
  const AddPhrase({Key? key}) : super(key: key);

  @override
  _AddPhraseState createState() => _AddPhraseState();
}

class _AddPhraseState extends State<AddPhrase> {
  dynamic decal;
  dynamic previewDecal;
  Mode phraseMode = Mode.icon;
  final ImagePicker _picker = ImagePicker();

  TextEditingController phraseController = TextEditingController();
  TextEditingController emojiController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      decal = image;
      previewDecal = image!.path;
    });
  }

  Future getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      decal = image;
      previewDecal = image!.path;
    });
  }

  Future getIcon() async {
    IconData? icon = await FlutterIconPicker.showIconPicker(
      context,
      iconPackModes: [IconPack.material],
      title: Text("Select Icon"),
    );
    setState(() {
      decal = icon!.codePoint;
      previewDecal = icon.codePoint;
    });
  }

  Future<List<Phrase>> getCustomPhrase() async {
    CustomPhrase customPhrase = CustomPhrase();
    return customPhrase.read();
  }

  Future<File> saveCustomPhrase(String phrase) async {
    CustomPhrase customPhrase = CustomPhrase();
    Phrase phraseToAdd =
        Phrase(phrase: phrase, decal: decal, phraseMode: phraseMode);
    return customPhrase.write(phraseToAdd);
  }

  void getEmoji() {
    setState(() {
      decal = emojiController.text;
      previewDecal = emojiController.text;
    });
  }

  Future<void> retrieveLostFile() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        decal = response.file;
      });
    } else {
      print(response.exception!.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Phrase"),
      ),
      body: FutureBuilder<void>(
          future: getCustomPhrase(),
          builder: (context, snapshot) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phrase',
                    ),
                    onChanged: (value) => phraseController.text = value,
                  ),
                ),
                //Radio group
                RadioListTile<Mode>(
                  title: const Text('Icon'),
                  value: Mode.icon,
                  groupValue: phraseMode,
                  onChanged: (value) {
                    setState(() {
                      phraseMode = Mode.icon;
                      decal = null;
                      previewDecal = null;
                    });
                  },
                ),
                RadioListTile<Mode>(
                  title: const Text('Image'),
                  value: Mode.image,
                  groupValue: phraseMode,
                  onChanged: (value) {
                    setState(() {
                      phraseMode = Mode.image;
                      decal = null;
                      previewDecal = null;
                    });
                  },
                ),
                RadioListTile<Mode>(
                  title: const Text('Emoji'),
                  value: Mode.emoji,
                  groupValue: phraseMode,
                  onChanged: (value) {
                    setState(() {
                      phraseMode = Mode.emoji;
                      decal = null;
                      previewDecal = null;
                    });
                  },
                ),

                ConditionedInput(phraseMode,
                    iconCallback: getIcon,
                    imageCallback: getImage,
                    emojiCallback: getEmoji,
                    emojiController: emojiController),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                    onPressed: () {
                      saveCustomPhrase(phraseController.text)
                          .then((value) => Navigator.pop(context));
                    },
                    child: const Text("Save"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxHeight: 200, maxWidth: 200),
                      child: ButtonPreview(
                          mode: phraseMode,
                          decal: previewDecal,
                          phrase: "Test")),
                )
              ],
            );
          }),
    );
  }
}

Widget ButtonPreview({mode, decal, phrase}) {
  if (decal == null) {
    return Text("No decal");
  } else {
    return GridView.count(
      crossAxisCount: 4,
      children: [
        Flex(direction: Axis.vertical, children: [
          PhraseButton(
              decal: decal,
              phrase: phrase,
              phraseMode: mode,
              onPressed: () => {})
        ])
      ],
    );
  }
}

Widget ConditionedInput(phraseMode,
    {required VoidCallback iconCallback,
    required VoidCallback imageCallback,
    required VoidCallback emojiCallback,
    required TextEditingController emojiController}) {
  if (phraseMode == Mode.icon) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
          onPressed: () {
            iconCallback();
          },
          child: const Text("Add Icon")),
    );
  } else if (phraseMode == Mode.image) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
          onPressed: () {
            imageCallback();
          },
          child: const Text("Add Image")),
    );
  } else if (phraseMode == Mode.emoji) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Emoji',
        ),
        controller: emojiController,
        onChanged: (value) {
          emojiCallback();
        },
        keyboardType: TextInputType.text,
      ),
    );
  } else {
    return Text("Error");
  }
}
