import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locallised_comms_app/models/Phrase.dart';

class PhraseButton extends StatefulWidget {
  PhraseButton(
      {super.key,
      required this.phrase,
      required this.decal,
      required this.onPressed,
      this.phraseMode});
  final String phrase;
  final dynamic decal;
  Mode? phraseMode;
  final VoidCallback onPressed;
  @override
  _PhraseButtonState createState() => _PhraseButtonState();
}

class _PhraseButtonState extends State<PhraseButton> {
  dynamic localDecal;
  @override
  Widget build(BuildContext context) {
    if (widget.phraseMode != null) {
      switch (widget.phraseMode) {
        case Mode.icon:
          localDecal = FittedBox(
            fit: BoxFit.fill,
            child: Icon(
              IconData(widget.decal, fontFamily: 'MaterialIcons'),
            ),
          );
          break;
        case Mode.image:
          localDecal = FittedBox(
              fit: BoxFit.fill,
              child: Image.file(File(widget.decal), fit: BoxFit.fitWidth));
          break;
        case Mode.emoji:
          localDecal = FittedBox(
            fit: BoxFit.fill,
            child: Text(
              widget.decal,
            ),
          );
          break;
        default:
      }
    }
    return Flexible(
      child: AspectRatio(
        aspectRatio: 1,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.primary,
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(aspectRatio: 1, child: localDecal),
            ],
          ),
        ),
      ),
    );
  }
}
