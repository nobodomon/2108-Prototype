import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locallised_comms_app/dal/CustomPhrase.dart';

import '../pages/add_phrase.dart';

enum Mode {
  icon,
  image,
  emoji,
}

class Phrase {
  String phrase;
  dynamic decal;
  Mode? phraseMode;

  Phrase({required this.phrase, this.decal, this.phraseMode}) {}

  get getPhrase => phrase;

  get getDecal {
    switch (phraseMode) {
      case Mode.icon:
        return Icon(IconData(decal, fontFamily: 'MaterialIcons'));
      case Mode.image:
        return Image.file(File(decal.path), fit: BoxFit.cover);
      case Mode.emoji:
        return Text(decal);
      default:
        return Container(
          color: Colors.grey,
          child: Center(
            child: Text(
              "error",
            ),
          ),
        );
    }
  }

  static Phrase fromJson(Map<String, dynamic> json) {
    if (json['phraseMode'] == 'Mode.icon') {
      print(json);
      return Phrase(
        phrase: json['phrase'],
        decal: json['decal'],
        phraseMode: Mode.icon,
      );
    } else if (json['phraseMode'] == 'Mode.image') {
      print(json);
      return Phrase(
        phrase: json['phrase'],
        decal: json['decal'],
        phraseMode: Mode.image,
      );
    } else {
      print(json);
      return Phrase(
        phrase: json['phrase'],
        decal: json['decal'],
        phraseMode: Mode.emoji,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'phrase': phrase,
      'decal': decal,
      'phraseMode': phraseMode.toString(),
    };
  }

  @override
  String toString() {
    return "$phrase $decal $phraseMode";
  }
}
