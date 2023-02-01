import 'package:flutter_tts/flutter_tts.dart';

class Utilities {
  static Future<List<String>> getVoiceNames() async {
    List<String> voiceNames = [];
    FlutterTts flutterTts = FlutterTts();
    Future voices = await flutterTts.getVoices;
    voices.then((value) => {
          for (var voice in value) {voiceNames.add(voice["name"])}
        });
    return voiceNames;
  }

  static Future<dynamic> getVoicesByLocale(String locale) async {
    Future voices = FlutterTts().getVoices;
    List<VoiceModel> voicesByLocale = [];
    voices.then((value) => {
          for (var voice in value)
            {
              print("L21: " + voice.toString()),
              if (voice["locale"] == locale)
                {
                  voicesByLocale.add(
                      VoiceModel(name: voice["name"], locale: voice["locale"]))
                }
            }
        });
    return voicesByLocale;
  }
}

class VoiceModel {
  final String name;
  final String locale;

  VoiceModel({required this.name, required this.locale});
}
