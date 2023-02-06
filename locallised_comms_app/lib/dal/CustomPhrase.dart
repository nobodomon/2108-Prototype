import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ulid/ulid.dart';

import '../models/Phrase.dart';

class CustomPhrase {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/customPhrases.json');
  }

  Future<List<Phrase>> read() async {
    try {
      final file = await _localFile;
      final localPath = await _localPath;

      if (!file.existsSync()) {
        return [];
      }
      final contents = await file.readAsString();
      List<dynamic> phrases = jsonDecode(contents);
      List<Phrase> phrasesList =
          phrases.map((e) => Phrase.fromJson(e)).toList();
      return phrasesList;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<File> write(Phrase phrase) async {
    if (phrase.phraseMode == Mode.image) {
      XFile saved = await copyFile(phrase.decal);
      phrase.decal = saved.path;
    }
    List<Phrase> phrases;
    if (await exists()) {
      phrases = await read();
      phrases.add(phrase);
    } else {
      phrases = [phrase];
    }
    final file = await _localFile;
    String phrasesString = jsonEncode(phrases);

    return file.writeAsString(phrasesString, flush: true);
  }

  Future<bool> exists() async {
    final file = await _localFile;
    return file.exists();
  }

  Future<XFile> copyFile(XFile image) async {
    try {
      final localPath = await _localPath;

      final imageContent = await image.readAsBytes();
      String fileULID = Ulid().toString();
      String newFileName = path.join(
          localPath, "images", "$fileULID.${image.path.split(".").last}");
      final File localFile = await File(newFileName).create(recursive: true);
      await localFile.writeAsBytes(imageContent);
      return XFile(newFileName);
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }
}
