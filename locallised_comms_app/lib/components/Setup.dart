import 'dart:convert';

class Setup {
  final int layout;
  final String language;
  final String voice;
  final String speed;
  final String pitch;
  final String volume;
  final String engine;
  final String voiceQuality;

  Setup({
    required this.layout,
    required this.language,
    required this.voice,
    required this.speed,
    required this.pitch,
    required this.volume,
    required this.engine,
    required this.voiceQuality,
  });

  static Setup fromJson(String contents) {
    final json = jsonDecode(contents);
    return Setup(
      layout: json['layout'],
      language: json['language'],
      voice: json['voice'],
      speed: json['speed'],
      pitch: json['pitch'],
      volume: json['volume'],
      engine: json['engine'],
      voiceQuality: json['voiceQuality'],
    );
  }

  String toJson() {
    return jsonEncode({
      'layout': layout,
      'language': language,
      'voice': voice,
      'speed': speed,
      'pitch': pitch,
      'volume': volume,
      'engine': engine,
      'voiceQuality': voiceQuality,
    });
  }
}
