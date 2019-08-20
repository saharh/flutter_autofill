//Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => AddressInputPage(currentOffer, _address)));

import 'package:flutter/material.dart';

import 'input_screen.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofill example app'),
      ),
      body: Center(
        child: RaisedButton(child: Text("Input Screen"), onPressed: () => _onPress(context)),
      ),
    );
  }

  void _onPress(context) {
    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => InputScreen()));
  }
}
