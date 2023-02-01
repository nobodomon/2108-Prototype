import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/Setup.dart';
import '../utilities/utilities.dart';

class SetupPage extends StatefulWidget {
  const SetupPage(
      {super.key, required this.title, required this.setupCallback});
  final String title;
  final VoidCallback setupCallback;

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  Future languages = FlutterTts().getLanguages;
  Future voices = FlutterTts().getVoices;
  FlutterTts flutterTts = FlutterTts();
  String sampleText = "Put the fork on the table!";
  TextEditingController _layoutController = TextEditingController();
  Map<String, dynamic> data = {
    "layout": "3",
    "language": "en-GB",
    "speed": 1.0,
    "voice": "en-GB-x-rjs#male_1-local",
  };
  @override
  void initState() {
    super.initState();
    _layoutController.text = sampleText;
  }

  void onChange(field, value) {
    setState(() {
      data[field] = value;
    });
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
              value: data["layout"],
              items: const [
                DropdownMenuItem(value: "1", child: Text("Normal Icons")),
                DropdownMenuItem(value: "2", child: Text("Large Icons")),
                DropdownMenuItem(value: "3", child: Text("Largest Icons")),
              ],
              onChanged: (value) => onChange("layout", value),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Language',
              ),
              icon: const Icon(Icons.language),
              value: data["language"],
              items: const [
                DropdownMenuItem(value: "en-GB", child: Text("English (UK)")),
                DropdownMenuItem(value: "en-US", child: Text("English (US)")),
                DropdownMenuItem(value: "zh-TW", child: Text("Chinese")),
                DropdownMenuItem(value: "ms-MY", child: Text("Malay")),
                DropdownMenuItem(value: "ta-IN", child: Text("Tamil")),
                DropdownMenuItem(value: "fr-FA", child: Text("French")),
                DropdownMenuItem(value: "it-IT", child: Text("Italian")),
              ],
              onChanged: (value) => onChange("language", value),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(15.0),
            //   child: FutureBuilder(
            //     future: Utilities.getVoicesByLocale(data["language"]),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         print(snapshot.data);
            //         return DropdownButtonFormField(
            //           decoration: const InputDecoration(
            //             border: OutlineInputBorder(),
            //             labelText: 'Voice',
            //           ),
            //           icon: const Icon(Icons.person),
            //           value: data["voice"],
            //           items: snapshot.data
            //               .map<DropdownMenuItem<String>>((VoiceModel e) {
            //             return DropdownMenuItem<String>(
            //                 value: e.name, child: Text(e.name));
            //           }).toList(),
            //           onChanged: (value) => onChange("voice", value),
            //         );
            //       } else {
            //         return const LinearProgressIndicator();
            //       }
            //     },
            //   ),
            // ),
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
            Text("Speed: " +
                (data["speed"] != null
                    ? data["speed"].toString()
                    : "Please select a speed")),
            const SizedBox(height: 15),
            Slider(
                divisions: 10,
                max: 2.0,
                min: 0.5,
                value: data["speed"] != null ? data["speed"] : 1.0,
                onChanged: (value) => {onChange("speed", value)}),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => onChange("speed", 0.5),
                        child: const Text("Slow")),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => onChange("speed", 0.75),
                        child: const Text("Normal")),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => onChange("speed", 1.0),
                        child: const Text("Fast")),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () async => {
                      await flutterTts.setLanguage(data["language"]),
                      await flutterTts.setSpeechRate(data["speed"].toDouble()),
                      flutterTts.speak(sampleText)
                    },
                child: Text("Test speech")),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: widget.setupCallback, child: const Text("Confirm"))
          ],
        ),
      ),
    );
  }
}
