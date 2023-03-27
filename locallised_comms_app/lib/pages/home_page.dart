import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/dal/CustomPhrase.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

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
  bool isPhrasePackAdded = false;
  TextEditingController textController = TextEditingController();
  PageController _pageController =
      PageController(initialPage: 0, keepPage: false);
  FlutterTts flutterTts = FlutterTts();
  CustomPhrase customPhrases = CustomPhrase();

  tryNext() {
    if (index == 2) {
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
    }
  }

  tryPrevious() {
    if (index == 0) {
      _pageController.animateToPage(3,
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
    } else {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 500), curve: Curves.linear);
    }
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

  void addPhrasePack(context) {
    setState(() {
      isPhrasePackAdded = !isPhrasePackAdded;
    });

    var response =
        (isPhrasePackAdded ? "Phrase Pack Added" : "Phrase Pack Removed");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.fixed,
      ),
    );
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _speak(context);
            },
            child: const Icon(
              Icons.speaker,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            onPressed: () async => {
              await Share.share(input).then((value) => {
                    setState(() {
                      textController.text = "";
                      currentWord = "";
                      input = "";
                      end = 0;
                    }),
                  })
            },
            tooltip: 'Add Phrase Pack',
            child: Icon(Icons.share),
          ),
        ],
      ),
      drawer: Drawer(
          backgroundColor: Theme.of(context).primaryColor,
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text("Locallised Comms"),
              ),
              ListTile(
                title: const Text("Setup"),
                onTap: () {
                  Navigator.pushNamed(context, '/setup');
                },
              ),
              ListTile(
                title: const Text("Add Phrase"),
                onTap: () {
                  Navigator.pushNamed(context, '/add-phrase');
                },
              ),
              ListTile(
                title: const Text("Remove Phrases"),
                onTap: () {
                  Navigator.pushNamed(context, '/remove-phrase');
                },
              ),
              ListTile(
                title: const Text("First Time Setup"),
                onTap: () {
                  Navigator.pushNamed(context, '/first-time-setup');
                },
              ),
            ],
          )),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return _MobileLayout(context);
        },
      ),
    );
  }

  Widget _DesktopLayout(context) {
    return Column(children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 100),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Flex(
            direction: Axis.horizontal,
            children: [],
          ),
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
              isPhrasePackAdded: isPhrasePackAdded,
              isMobile: false,
              setup: widget.setup,
              appendTextField: appendTextField,
            ),
            CustomPhrasesLayout(
              isMobile: false,
              setup: widget.setup,
              appendTextField: appendTextField,
            ),
            const Center(child: Text("Voice Packs will appear here")),
          ],
        ),
      ),
      _bottomTextBar()
    ]);
  }

  Widget _MobileLayout(context) {
    return Column(children: [
      _bottomTextBar(),
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
              isPhrasePackAdded: isPhrasePackAdded,
              isMobile: true,
              setup: widget.setup,
              appendTextField: appendTextField,
            ),
            CustomPhrasesLayout(
              isMobile: true,
              setup: widget.setup,
              appendTextField: appendTextField,
            ),
            AddPackLayout(
              isPhrasePackAdded: isPhrasePackAdded,
              isMobile: true,
              setup: widget.setup,
              addPhrasePack: () => {addPhrasePack(context)},
            )
          ],
        ),
      ),
    ]);
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
          ],
        ));
  }
}

class DefaultPhraseLayout extends StatelessWidget {
  final bool isPhrasePackAdded;
  final Setup setup;
  final bool isMobile;
  final List<List<dynamic>> phrases = [
    ["I want to eat ", Icons.lunch_dining.codePoint],
    ["I need to go to the toilet ", Icons.bathtub.codePoint],
    ["I am going to bed ", Icons.bed.codePoint],
    ["How are you ", Icons.sentiment_satisfied.codePoint],
    ["Have you eaten ", Icons.food_bank.codePoint],
  ];

  final List<List<dynamic>> phrasesExtended = [
    ["I want to eat ", Icons.lunch_dining.codePoint],
    ["I need to go to the toilet ", Icons.bathtub.codePoint],
    ["I am going to bed ", Icons.bed.codePoint],
    ["How are you ", Icons.sentiment_satisfied.codePoint],
    ["Have you eaten ", Icons.food_bank.codePoint],
    ["I want to eat ", Icons.lunch_dining.codePoint],
    ["I need to go to the toilet ", Icons.bathtub.codePoint],
    ["I am going to bed ", Icons.bed.codePoint],
    ["How are you ", Icons.sentiment_satisfied.codePoint],
    ["Have you eaten ", Icons.food_bank.codePoint],
  ];

  final Function appendTextField;
  DefaultPhraseLayout(
      {Key? key,
      required this.isPhrasePackAdded,
      required this.appendTextField,
      required this.setup,
      required this.isMobile})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Default Phrases",
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: isMobile ? setup.layout : setup.layout * 2,
            padding: const EdgeInsets.all(15),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: <Widget>[
              for (List<dynamic> phrase
                  in (isPhrasePackAdded ? phrasesExtended : phrases))
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
          ),
        ),
      ],
    );
  }
}

class CustomPhrasesLayout extends StatelessWidget {
  final Setup setup;
  final Function appendTextField;
  final bool isMobile;
  const CustomPhrasesLayout(
      {Key? key,
      required this.setup,
      required this.appendTextField,
      required this.isMobile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomPhrase customPhrases = CustomPhrase();
    return FutureBuilder(
        future: customPhrases.read(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                const Text(
                  "Custom Phrases",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.start,
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: isMobile ? setup.layout : setup.layout * 2,
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
                  ),
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

class AddPackLayout extends StatelessWidget {
  final Setup setup;
  final bool isMobile;
  final List<List<dynamic>> phrases = [
    ["Singlish ", Icons.lunch_dining.codePoint],
    ["Chinese ", Icons.bathtub.codePoint],
    ["Tiktok trends ", Icons.bed.codePoint],
  ];
  final Function addPhrasePack;
  final bool isPhrasePackAdded;

  handleAddPhrase(context) {
    addPhrasePack();
  }

  AddPackLayout(
      {Key? key,
      required this.addPhrasePack,
      required this.isPhrasePackAdded,
      required this.setup,
      required this.isMobile})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Phrase Packs",
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 20),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: isMobile ? setup.layout : setup.layout * 2,
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
                      onPressed: () => handleAddPhrase(context),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
