import 'package:flutter/material.dart';

class PhraseButton extends StatefulWidget {
  const PhraseButton(
      {super.key,
      required this.phrase,
      required this.icon,
      required this.onPressed});
  final String phrase;
  final Icon icon;
  final VoidCallback onPressed;
  @override
  _PhraseButtonState createState() => _PhraseButtonState();
}

class _PhraseButtonState extends State<PhraseButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: widget.icon),
            ],
          ),
        ),
      ),
    );
  }
}
