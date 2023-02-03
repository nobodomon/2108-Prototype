import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/dal/CustomPhrase.dart';

import '../models/Phrase.dart';
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
  int index = 0;
  TextEditingController textController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();

  tryNext() {
    if (index == 2) {
      setState(() {
        index = 0;
      });
    } else {
      setState(() {
        index++;
      });
    }
  }

  tryPrevious() {
    if (index == 0) {
      setState(() {
        index = 2;
      });
    } else {
      setState(() {
        index--;
      });
    }
  }

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
                phraseMode: Mode.icon,
                decal: Icons.settings.codePoint,
              ),
              const SizedBox(
                width: 15,
              ),
              PhraseButton(
                onPressed: () => {
                  Navigator.pushNamed(context, '/add-phrase'),
                },
                phrase: "Test",
                phraseMode: Mode.icon,
                decal: Icons.add.codePoint,
              ),
              const SizedBox(
                width: 15,
              ),
              PhraseButton(
                onPressed: () => {tryPrevious()},
                phrase: "Test",
                phraseMode: Mode.icon,
                decal: Icons.chevron_left.codePoint,
              ),
              const SizedBox(
                width: 15,
              ),
              PhraseButton(
                onPressed: () => {tryNext()},
                phrase: "Test",
                phraseMode: Mode.icon,
                decal: Icons.chevron_right.codePoint,
              ),
            ],
          ),
        ),
        Flexible(
          child: index == 0
              ? defaultPhrases()
              : index == 1
                  ? customPhrases()
                  : Container(),
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

  Widget defaultPhrases() {
    return GridView(
      padding: const EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: widget.setup.layout,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15),
      children: <Widget>[
        PhraseButton(
          phrase: "I want to eat ",
          decal: Icons.lunch_dining.codePoint,
          phraseMode: Mode.icon,
          onPressed: () => appendTextField("I want to eat "),
        ),
        PhraseButton(
          phrase: "I need to go to the toilet ",
          decal: Icons.bathtub.codePoint,
          phraseMode: Mode.icon,
          onPressed: () => appendTextField("I need to go to the toilet "),
        ),
        PhraseButton(
          phrase: "I am going to bed ",
          decal: Icons.bed.codePoint,
          phraseMode: Mode.icon,
          onPressed: () => appendTextField("I am going to bed "),
        ),
        PhraseButton(
          phrase: "How are you ",
          decal: Icons.face.codePoint,
          phraseMode: Mode.icon,
          onPressed: () => appendTextField("How are you "),
        ),
        PhraseButton(
          phrase: "Have you eaten",
          decal: Icons.lunch_dining_rounded.codePoint,
          phraseMode: Mode.icon,
          onPressed: () => appendTextField("Have you eaten "),
        ),
      ],
    );
  }

  Widget customPhrases() {
    CustomPhrase customPhrases = CustomPhrase();
    return FutureBuilder(
        future: customPhrases.read(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return GridView(
              padding: const EdgeInsets.all(15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1,
                  crossAxisCount: widget.setup.layout,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15),
              children: <Widget>[
                for (Phrase phrase in snapshot.data)
                  PhraseButton(
                    phrase: phrase.phrase,
                    decal: phrase.decal,
                    phraseMode: phrase.phraseMode,
                    onPressed: () => appendTextField(phrase.phrase),
                  ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
