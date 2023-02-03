import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/pages/add_phrase.dart';
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
  Future exists = SetupDal().exists();
  Future<Setup>? setup;
  @override
  void initState() {
    SetupDal dal = SetupDal();
    dal.exists().then((value) async => {
          if (value == false)
            {}
          else
            {
              {
                setup = dal.read(),
              }
            }
        });
    super.initState();
  }

  void setupCompleteCallback() {
    print("Setup Complete Callback");
    setState(() {
      exists = SetupDal().exists();
      setup = SetupDal().read();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          '/setup': (context) => FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SetupPage(
                      title: widget.title,
                      setup: snapshot.data as Setup,
                      setupCallback: setupCompleteCallback);
                } else {
                  return const CircularProgressIndicator();
                }
              },
              future: setup),
          '/home': (context) => FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return HomePage(
                      title: widget.title, setup: snapshot.data as Setup);
                } else {
                  return const CircularProgressIndicator();
                }
              },
              future: setup),
          '/add-phrase': (context) => AddPhrase()
        },
        title: 'Flutter Demo',
        theme: ThemeData(
            brightness: Brightness.light, colorSchemeSeed: Colors.indigo),
        darkTheme: ThemeData(
            brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
        home: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == true) {
                return FutureBuilder(
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return HomePage(
                            title: widget.title, setup: snapshot.data as Setup);
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                    future: SetupDal().read());
              } else {
                return SetupPage(
                    title: widget.title, setupCallback: setupCompleteCallback);
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
          future: exists,
        ));
  }
}
