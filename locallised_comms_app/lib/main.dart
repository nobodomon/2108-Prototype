import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:locallised_comms_app/components/phrase_button.dart';
import 'package:locallised_comms_app/dal/setupDal.dart';
import 'package:locallised_comms_app/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';

import 'components/Setup.dart';
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
    setup_dal dal = setup_dal();
    dal.exists().then((value) async => {
          if (value == false)
            {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SetupPage(
                          title: widget.title,
                          setupCallback: setupCompleteCallback)))
            }
          else
            {setup = await dal.read()}
        });
    super.initState();
  }

  setupCompleteCallback() {
    setState(() async {
      setup = await setup_dal().read();
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
      home: const HomePage(title: 'Localised Comms App'),
    );
  }
}
