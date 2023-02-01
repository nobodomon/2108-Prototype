import 'dart:convert';

class Setup {
  int layout;
  String language;
  String voice;
  String speed;

  Setup({
    required this.layout,
    required this.language,
    required this.voice,
    required this.speed,
  });

  static Setup fromJson(String contents) {
    final json = jsonDecode(contents);
    return Setup(
      layout: json['layout'],
      language: json['language'],
      voice: json['voice'],
      speed: json['speed'],
    );
  }

  String toJson() {
    return jsonEncode({
      'layout': layout,
      'language': language,
      'voice': voice,
      'speed': speed,
    });
  }
}
