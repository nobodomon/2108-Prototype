import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/dal/CustomPhrase.dart';
import 'package:path/path.dart';

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
  String currentWord = "";
  int index = 0;
  int end = 0;
  TextEditingController textController = TextEditingController();
  PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  FlutterTts flutterTts = FlutterTts();
  CustomPhrase customPhrases = CustomPhrase();

  tryNext() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  tryPrevious() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    initTTS(context);
  }

  void initTTS(context) {
    flutterTts.setLanguage(widget.setup.language);
    flutterTts.setVoice(
        {"name": widget.setup.voice, "locale": widget.setup.language});
    flutterTts.setSpeechRate(widget.setup.speed);
    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      setState(() {
        end = endOffset;
        currentWord = word;
        input = word;
      });
    });
    flutterTts.setCompletionHandler(() {
      Navigator.pop(context);
    });
  }

  void appendTextField(text) {
    setState(() {
      input += text;
    });
    textController.text = input;
  }

  Future _speak(context) async {
    if (input.isEmpty) {
      return;
    } else {
      await flutterTts.awaitSpeakCompletion(true);
      _showSpeechDialog(context);
      var result = await flutterTts.speak(input);
      if (result == 1) {
        Navigator.of(context).pop();
        setState(() {
          currentWord = "";
          textController.text = "";
          input = "";
          end = 0;
        });
      }
    }
  }

  Future _stop(context) async {
    var result = await flutterTts.stop();
    if (result == 1) {
      Navigator.of(context).pop();
      setState(() {
        textController.text = "";
        currentWord = "";
        input = "";
        end = 0;
      });
    }
  }

  Future<void> _showSpeechDialog(context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Speech in progress..."),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(currentWord),
                _textProgress(context),
              ]),
              actions: [
                IconButton(
                    onPressed: () => {_stop(context)},
                    icon: const Icon(Icons.stop)),
              ],
            );
          });
        });
  }

  Widget _textProgress(context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        LinearProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            value: end / input.length.toDouble()),
        IconButton(
          onPressed: flutterTts.pauseHandler,
          icon: const Icon(Icons.pause),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: () async {
            await _speak(context);
          },
          child: const Icon(
            Icons.speaker,
          ),
        ),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Flex(
            direction: Axis.horizontal,
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
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                this.index = index;
              });
            },
            children: [
              DefaultPhraseLayout(
                setup: widget.setup,
                appendTextField: appendTextField,
              ),
              CustomPhrasesLayout(
                setup: widget.setup,
                appendTextField: appendTextField,
              ),
              Container(),
            ],
          ),
        ),
        _bottomTextBar()
      ]),
    );
  }

  Widget _bottomTextBar() {
    return ConstrainedBox(
        constraints:
            const BoxConstraints.expand(height: 100, width: double.maxFinite),
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
        ));
  }
}

class DefaultPhraseLayout extends StatelessWidget {
  final Setup setup;
  final List<List<dynamic>> phrases = [
    ["I want to eat ", Icons.lunch_dining.codePoint],
    ["I need to go to the toilet ", Icons.bathtub.codePoint],
    ["I am going to bed ", Icons.bed.codePoint],
    ["How are you ", Icons.sentiment_satisfied.codePoint],
    ["Have you eaten ", Icons.food_bank.codePoint],
  ];
  final Function appendTextField;
  DefaultPhraseLayout(
      {Key? key, required this.appendTextField, required this.setup})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: setup.layout,
      padding: const EdgeInsets.all(15),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: <Widget>[
        for (List<dynamic> phrase in phrases)
          Flex(
            direction: Axis.vertical,
            children: [
              PhraseButton(
                phrase: phrase[0],
                decal: phrase[1],
                phraseMode: Mode.icon,
                onPressed: () => appendTextField(phrase[0]),
              ),
            ],
          ),
      ],
    );
  }
}

class CustomPhrasesLayout extends StatelessWidget {
  final Setup setup;
  final Function appendTextField;
  const CustomPhrasesLayout(
      {Key? key, required this.setup, required this.appendTextField})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomPhrase customPhrases = CustomPhrase();
    return FutureBuilder(
        future: customPhrases.read(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              crossAxisCount: setup.layout,
              padding: const EdgeInsets.all(15),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: <Widget>[
                for (Phrase phrase in snapshot.data)
                  Flex(
                    direction: Axis.vertical,
                    children: [
                      PhraseButton(
                        phrase: phrase.phrase,
                        decal: phrase.decal,
                        phraseMode: phrase.phraseMode,
                        onPressed: () => appendTextField(phrase.phrase),
                      ),
                    ],
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
