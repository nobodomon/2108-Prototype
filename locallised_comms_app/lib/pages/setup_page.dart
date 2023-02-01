import 'package:flutter/material.dart';

class SetupPage extends StatefulWidget {
  const SetupPage(
      {super.key, required this.title, required this.setupCallback});
  final String title;
  final VoidCallback setupCallback;

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: widget.setupCallback, child: const Text("Confirm"))
          ],
        ),
      ),
    );
  }
}
