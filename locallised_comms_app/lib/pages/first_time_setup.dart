import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../dal/SetupDal.dart';
import '../models/Setup.dart';
import '../utilities/utilities.dart';

class FirstTimeSetup extends StatefulWidget {
  const FirstTimeSetup({
    super.key,
    required this.title,
    required this.setupCallback,
  });

  final String title;
  final VoidCallback setupCallback;
  @override
  _FirstTimeSetupState createState() => _FirstTimeSetupState();
}

class _FirstTimeSetupState extends State<FirstTimeSetup> {
  Future languages = FlutterTts().getLanguages;
  Future? voices;
  FlutterTts flutterTts = FlutterTts();

  TextEditingController sampleTextController = TextEditingController();

  int currentStep = 0;

  SetupDal setupDal = SetupDal();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    fetchVoices('en-GB');
    super.initState();
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

  validate(step) {
    switch (step) {
      case 0:
        if (layout == null) {
          return false;
        }
        break;
      case 1:
        if (language == null) {
          return false;
        } else {
          fetchVoices(language!);
          sampleTextController.text = testPhrases[language]!;
        }
        break;
      case 2:
        if (voice == null) {
          return false;
        }
        break;
      case 3:
        if (speed == null) {
          return false;
        }
        break;
    }
    return true;
  }

  Map<String, String> testPhrases = {
    'en-GB': 'Put the fork on the table!',
    'en-US': 'Put the fork on the table!',
    'zh-TW': '把叉子放在桌子上！',
    'ms-MY': 'letak garfu di atas meja',
    'ta-IN': 'வட்டில் கார்ப்பை வைத்துக் கொள்ளுங்கள்',
  };

  // Setup layout
  // Setup language
  // Setup voice

  List<Step> setupSteps() {
    return <Step>[
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        title: const Text('Layout'),
        content: Column(
          children: <Widget>[
            RadioListTile(
              title: const Text('Severely disabled'),
              value: '1',
              groupValue: layout,
              onChanged: (String? value) {
                setState(() {
                  layout = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('Moderately disabled'),
              value: '2',
              groupValue: layout,
              onChanged: (String? value) {
                setState(() {
                  layout = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('Mildly disabled'),
              value: '3',
              groupValue: layout,
              onChanged: (String? value) {
                setState(() {
                  layout = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('Normal'),
              value: '4',
              groupValue: layout,
              onChanged: (String? value) {
                setState(() {
                  layout = value;
                });
              },
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        title: const Text('Language'),
        content: Column(
          children: <Widget>[
            RadioListTile(
              title: const Text('English (UK)'),
              value: 'en-GB',
              groupValue: language,
              onChanged: (String? value) {
                setState(() {
                  language = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('English (US)'),
              value: 'en-US',
              groupValue: language,
              onChanged: (String? value) {
                setState(() {
                  language = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('Malay'),
              value: 'ms-MY',
              groupValue: language,
              onChanged: (String? value) {
                setState(() {
                  language = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('Chinese'),
              value: 'zh-TW',
              groupValue: language,
              onChanged: (String? value) {
                setState(() {
                  language = value;
                });
              },
            ),
            RadioListTile(
              title: const Text('Tamil'),
              value: 'ta-IN',
              groupValue: language,
              onChanged: (String? value) {
                setState(() {
                  language = value;
                });
              },
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        title: const Text('Voice'),
        content: Column(
          children: <Widget>[
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
                labelText: 'This is a sample',
              ),
              controller: sampleTextController,
              enabled: false,
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
                      flutterTts.speak(sampleTextController.text)
                    },
                child: Text("Test speech")),
          ],
        ),
      ),
    ];
  }

  String? layout;
  String? language = 'en-GB';
  String? voice;
  double? speed;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Voice Abang'),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() {
                currentStep = currentStep - 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
          onStepContinue: () {
            if (currentStep < setupSteps().length - 1) {
              if (validate(currentStep)) {
                setState(() {
                  currentStep = currentStep + 1;
                });
              }
            } else {
              writeNewSetup();
            }
          },
          onStepTapped: (int step) {
            setState(() {
              currentStep = step;
            });
          },
          steps: setupSteps(),
        ));
  }
}
