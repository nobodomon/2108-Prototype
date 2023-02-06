import 'package:flutter/material.dart';
import 'package:locallised_comms_app/dal/CustomPhrase.dart';

import '../models/Phrase.dart';

class RemovePhrase extends StatefulWidget {
  const RemovePhrase({Key? key}) : super(key: key);

  @override
  _RemovePhraseState createState() => _RemovePhraseState();
}

class _RemovePhraseState extends State<RemovePhrase> {
  CustomPhrase customPhrase = CustomPhrase();

  Future<List<Phrase>> getCustomPhrase = CustomPhrase().read();

  Future<void> _showConfirmationDialog(Phrase phrase) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Phrase'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this phrase?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await customPhrase.deleteCustomPhrase(phrase);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remove Phrase'),
      ),
      body: FutureBuilder(
        future: getCustomPhrase,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(snapshot.data[index].phrase),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      _showConfirmationDialog(snapshot.data[index])
                          .then((value) => setState(() {
                                getCustomPhrase = customPhrase.read();
                              }));
                    },
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
