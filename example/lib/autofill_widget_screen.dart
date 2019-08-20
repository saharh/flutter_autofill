//Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => AddressInputPage(currentOffer, _address)));

import 'package:flutter/material.dart';
import 'package:flutter_autofill/autofill_widget.dart';
import 'package:flutter_autofill/flutter_autofill.dart';

class AutofillWidgetScreen extends StatelessWidget {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofill Widget screen'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          await FlutterAutofill.cancel();
          return true;
        },
        child: Center(
            child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              child: Autofill(
                onValueChanged: (val) {
                  _emailController.value = TextEditingValue(text: val, selection: TextSelection.fromPosition(TextPosition(offset: val.length)));
                },
                autofillHints: [FlutterAutofill.AUTOFILL_HINT_EMAIL_ADDRESS],
                autofillType: FlutterAutofill.AUTOFILL_TYPE_TEXT,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "Please enter your email", hasFloatingPlaceholder: false, border: UnderlineInputBorder()),
                  style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
