import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String input = "";
  TextEditingController textController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();

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
                onPressed: () => {},
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
        Expanded(
            child: GridView(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 4,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15),
          children: <Widget>[
            PhraseButton(
              phrase: "Test",
              icon: Icon(Icons.edit),
              onPressed: () => appendTextField("Test"),
            ),
            PhraseButton(
              phrase: "Test",
              icon: Icon(Icons.edit),
              onPressed: () => appendTextField("Test"),
            ),
            PhraseButton(
              phrase: "Test",
              icon: Icon(Icons.edit),
              onPressed: () => appendTextField("Test"),
            ),
            PhraseButton(
              phrase: "Test",
              icon: Icon(Icons.edit),
              onPressed: () => appendTextField("Test"),
            ),
            PhraseButton(
              phrase: "Test",
              icon: Icon(Icons.edit),
              onPressed: () => appendTextField("Test"),
            ),
          ],
        )),
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
