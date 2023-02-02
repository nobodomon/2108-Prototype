import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/Setup.dart';

class SetupDal {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/setup.json');
  }

  Future<Setup> read() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return Setup.fromJson(contents);
    } catch (e) {
      throw Exception('Failed to read file');
    }
  }

  Future<File> write(Setup setup) async {
    print("Writing Setup: " + setup.toJson());
    final file = await _localFile;
    return file.writeAsString(setup.toJson());
  }

  Future<bool> exists() async {
    final file = await _localFile;
    return file.exists();
  }
}
