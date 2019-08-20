//Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => AddressInputPage(currentOffer, _address)));

import 'package:flutter/material.dart';

class CompleteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete screen'),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Form completed!"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: RaisedButton(
              child: Text("Close"),
              onPressed: () => _onPress(context),
            ),
          )
        ],
      )),
    );
  }

  void _onPress(context) {
//    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => MenuScreen()));
    Navigator.pop(context);
  }
}
