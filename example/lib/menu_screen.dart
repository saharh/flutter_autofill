//Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => AddressInputPage(currentOffer, _address)));

import 'package:flutter/material.dart';

import 'autofill_widget_screen.dart';
import 'input_screen.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofill example app'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              RaisedButton(child: Text("Input Fields Demo"), onPressed: () => _onPress(context)),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: RaisedButton(child: Text("Autofill Widget Demo"), onPressed: () => _onWidgetDemoPress(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPress(context) {
    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => InputScreen()));
  }

  void _onWidgetDemoPress(context) {
    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => AutofillWidgetScreen()));
  }
}
