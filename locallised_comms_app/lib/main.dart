import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';

import 'models/Setup.dart';
import 'dal/SetupDal.dart';
import 'pages/setup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  final title = 'Localised Comms App';
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Setup setup;
  @override
  void initState() {
    super.initState();
    SetupDal dal = SetupDal();
    dal.exists().then((value) async => {
          if (value == false) {} else {setup = await dal.read()}
        });
    super.initState();
  }

  setupCompleteCallback() {
    setState(() async {
      setup = await SetupDal().read();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            brightness: Brightness.light, colorSchemeSeed: Colors.indigo),
        darkTheme: ThemeData(
            brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
        home: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return HomePage(title: widget.title, setup: setup);
              } else {
                return SetupPage(
                    title: widget.title, setupCallback: setupCompleteCallback);
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
          future: SetupDal().exists(),
        ));
  }
}
