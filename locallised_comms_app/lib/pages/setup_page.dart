import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/dal/SetupDal.dart';

import '../models/Setup.dart';
import '../utilities/utilities.dart';

class SetupPage extends StatefulWidget {
  SetupPage(
      {super.key,
      required this.title,
      required this.setupCallback,
      this.setup});
  final String title;
  final VoidCallback setupCallback;
  Setup? setup;

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  Future languages = FlutterTts().getLanguages;
  Future? voices;
  FlutterTts flutterTts = FlutterTts();

  String sampleText = "Put the fork on the table!";
  TextEditingController _layoutController = TextEditingController();

  SetupDal setupDal = SetupDal();

  String? layout;
  String? language;
  String? voice;
  double? speed;

  @override
  void dispose() {
    _layoutController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.setup == null) {
      layout = "4";
      language = "en-GB";
      voice = "";
      speed = 0.65;
    } else {
      layout = widget.setup!.layout.toString();
      language = widget.setup!.language;
      voice = widget.setup!.voice;
      speed = widget.setup!.speed;
    }

    _layoutController.text = sampleText;
    fetchVoices(language!);
  }

  void fetchVoices(String locale) {
    //fake 1s timeout
    setState(() {
      voices = Utilities.getVoicesByLocale(locale);
    });
  }

  writeNewSetup() async {
    try {
      Setup setup = Setup(
          layout: int.parse(layout!),
          language: language!,
          voice: voice!,
          speed: speed!);
      await setupDal.write(setup);
      widget.setupCallback();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Layout',
              ),
              icon: const Icon(Icons.grid_view),
              value: layout,
              items: const [
                DropdownMenuItem(value: "4", child: Text("Small Icons")),
                DropdownMenuItem(value: "3", child: Text("Medium Icons")),
                DropdownMenuItem(value: "2", child: Text("Large Icons")),
                DropdownMenuItem(value: "1", child: Text("Largest Icons")),
              ],
              onChanged: (value) => setState(() {
                layout = value.toString();
              }),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Language',
              ),
              icon: const Icon(Icons.language),
              value: language,
              items: const [
                DropdownMenuItem(value: "en-GB", child: Text("English (UK)")),
                DropdownMenuItem(value: "en-US", child: Text("English (US)")),
                DropdownMenuItem(value: "zh-TW", child: Text("Chinese")),
                DropdownMenuItem(value: "ms-MY", child: Text("Malay")),
                DropdownMenuItem(value: "ta-IN", child: Text("Tamil")),
                DropdownMenuItem(value: "fr-FR", child: Text("French")),
                DropdownMenuItem(value: "it-IT", child: Text("Italian")),
              ],
              onChanged: (value) {
                setState(() {
                  language = value;
                  voice = "";
                });
                fetchVoices(language!);
              },
            ),
            const SizedBox(height: 15),
            FutureBuilder(
              future: voices!,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.length > 0) {
                  for (var i = 0; i < snapshot.data.length; i++) {}
                  return DropdownButtonFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Voice',
                    ),
                    value: voice != "" ? voice : snapshot.data![0].name,
                    icon: const Icon(Icons.person),
                    items: snapshot.data
                        .map<DropdownMenuItem<String>>((VoiceModel e) {
                      return DropdownMenuItem<String>(
                          value: e.name.toString(), child: Text(e.name));
                    }).toList(),
                    onChanged: (value) => setState(() {
                      voice = value.toString();
                    }),
                  );
                } else {
                  return const LinearProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Sample Text',
              ),
              controller: _layoutController,
              onChanged: (value) => {
                setState(() {
                  sampleText = value;
                })
              },
            ),
            const SizedBox(height: 15),
            Text("Speed: $speed"),
            const SizedBox(height: 15),
            Slider(
                divisions: 10,
                max: 2.0,
                min: 0.5,
                value: speed != null ? speed! : 1.0,
                onChanged: (value) => setState(() {
                      speed = value;
                    })),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => setState(() {
                              speed = 0.5;
                            }),
                        child: const Text("Slow")),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => setState(() {
                              speed = 0.75;
                            }),
                        child: const Text("Normal")),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => setState(() {
                              speed = 1.0;
                            }),
                        child: const Text("Fast")),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () async => {
                      await flutterTts.setLanguage(language!),
                      await flutterTts.setSpeechRate(speed!),
                      await flutterTts
                          .setVoice({"name": voice!, "locale": language!}),
                      flutterTts.speak(sampleText)
                    },
                child: Text("Test speech")),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () async {
                  writeNewSetup();
                  widget.setupCallback;
                  Navigator.pop(context);
                },
                child: const Text("Confirm"))
          ],
        ),
      ),
    );
  }
}
