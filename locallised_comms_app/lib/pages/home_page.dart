import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';

import '../models/Setup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title, required this.setup});
  final String title;
  final Setup setup;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String input = "";
  TextEditingController textController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    // TODO: implement initState
    flutterTts.setLanguage(widget.setup.language);
    flutterTts.setVoice(
        {"name": widget.setup.voice, "locale": widget.setup.language});
    flutterTts.setSpeechRate(widget.setup.speed);

    super.initState();
  }

  void appendTextField(text) {
    setState(() {
      input += text;
    });
    textController.text = input;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => {
          await flutterTts.speak(input).then((value) => {
                textController.text = "",
              }),
          setState(() {
            input = "";
          })
        },
        child: Icon(
          Icons.speaker,
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              PhraseButton(
                onPressed: () => {
                  Navigator.pushNamed(context, '/setup'),
                },
                phrase: "Test",
                icon: Icon(Icons.settings),
              ),
              SizedBox(
                width: 15,
              ),
              PhraseButton(
                onPressed: () => {},
                phrase: "Test",
                icon: Icon(Icons.chevron_left),
              ),
              SizedBox(
                width: 15,
              ),
              PhraseButton(
                onPressed: () => {},
                phrase: "Test",
                icon: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Flexible(
          child: GridView(
            padding: const EdgeInsets.all(15),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: widget.setup.layout,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15),
            children: <Widget>[
              PhraseButton(
                phrase: "I want to eat ",
                icon: Icon(Icons.lunch_dining),
                onPressed: () => appendTextField("I want to eat "),
              ),
              PhraseButton(
                phrase: "I need to go to the toilet ",
                icon: Icon(Icons.bathtub),
                onPressed: () => appendTextField("I need to go to the toilet "),
              ),
              PhraseButton(
                phrase: "I am going to bed ",
                icon: Icon(Icons.bed),
                onPressed: () => appendTextField("I am going to bed "),
              ),
              PhraseButton(
                phrase: "How are you ",
                icon: Icon(Icons.face),
                onPressed: () => appendTextField("How are you "),
              ),
              PhraseButton(
                phrase: "Have you eaten",
                icon: Icon(Icons.lunch_dining_rounded),
                onPressed: () => appendTextField("Have you eaten "),
              ),
            ],
          ),
        ),
      ]),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
            ),
          ],
        ),
        child: ConstrainedBox(
            constraints:
                BoxConstraints.expand(height: 100, width: double.maxFinite),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.top,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    controller: textController,
                    enabled: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    child: const Text("Whatsapp/Telegram"),
                    onPressed: () => {},
                  ),
                ),
              ],
            )),
      ), //ailing comma makes auto-formatting nicer for build methods.
    );
  }
}
