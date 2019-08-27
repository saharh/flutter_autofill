import 'package:flutter/material.dart';
import 'package:flutter_autofill/flutter_autofill.dart';

class AutofillWidgetScreen extends StatefulWidget {
  @override
  _AutofillWidgetScreenState createState() => _AutofillWidgetScreenState();
}

class _AutofillWidgetScreenState extends State<AutofillWidgetScreen> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
                onAutofilled: (val) {
                  _emailController.value = TextEditingValue(text: val, selection: TextSelection.fromPosition(TextPosition(offset: val.length)));
                },
                autofillHints: [FlutterAutofill.AUTOFILL_HINT_EMAIL_ADDRESS],
                autofillType: FlutterAutofill.AUTOFILL_TYPE_TEXT,
                textController: _emailController,
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
