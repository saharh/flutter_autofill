import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill/flutter_autofill.dart';

import 'complete_screen.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  static const String ID_EMAIL_INPUT = "email_input";
  TextEditingController _emailController = TextEditingController();
  final GlobalKey _emailKey = GlobalKey();
  final FocusNode _emailFocus = FocusNode();

  static const String ID_PHONE_NUM_INPUT = "phone_num_input";
  TextEditingController _phoneNumController = TextEditingController();
  final GlobalKey _phoneNumKey = GlobalKey();
  final FocusNode _phoneNumFocus = FocusNode();

  static const String ID_CC_NUM_INPUT = "cc_num_input";
  TextEditingController _ccNumController = TextEditingController();
  final GlobalKey _ccNumKey = GlobalKey();
  final FocusNode _ccNumFocus = FocusNode();

  static const String ID_CC_EXP_DATE_INPUT = "cc_exp_date_input";
  TextEditingController _ccExpDateController = TextEditingController();
  final GlobalKey _ccExpDateKey = GlobalKey();
  final FocusNode _ccExpDateFocus = FocusNode();

  bool commited = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (!mounted) return;

    Stream emailStream = await FlutterAutofill.registerWidget(
        context, ID_EMAIL_INPUT, _emailFocus, _emailKey, [FlutterAutofill.AUTOFILL_HINT_EMAIL_ADDRESS], FlutterAutofill.AUTOFILL_TYPE_TEXT);
    emailStream?.listen((text) {
      setState(() {
        _emailController.value = TextEditingValue(text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
      });
    });

    Stream phoneNumStream = await FlutterAutofill.registerWidget(
        context, ID_PHONE_NUM_INPUT, _phoneNumFocus, _phoneNumKey, [FlutterAutofill.AUTOFILL_HINT_PHONE], FlutterAutofill.AUTOFILL_TYPE_TEXT);
    phoneNumStream?.listen((text) {
      setState(() {
        _phoneNumController.value = TextEditingValue(text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
      });
    });

    Stream ccNumStream = await FlutterAutofill.registerWidget(
        context, ID_CC_NUM_INPUT, _ccNumFocus, _ccNumKey, [FlutterAutofill.AUTOFILL_HINT_CREDIT_CARD_NUMBER], FlutterAutofill.AUTOFILL_TYPE_TEXT);
    ccNumStream?.listen((text) {
      setState(() {
        _ccNumController.value = TextEditingValue(text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
      });
    });

    Stream ccExpDateStream = await FlutterAutofill.registerWidget(context, ID_CC_EXP_DATE_INPUT, _ccExpDateFocus, _ccExpDateKey,
        [FlutterAutofill.AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_DATE], FlutterAutofill.AUTOFILL_TYPE_DATE);
    ccExpDateStream?.listen((value) {
      DateTime expDate = DateTime.fromMillisecondsSinceEpoch(value);
      String text = "${expDate.year.toString()}-${expDate.month.toString().padLeft(2, '0')}-${expDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _ccExpDateController.value = TextEditingValue(text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
      });
    });

//    FlutterAutofill.afTextStream.listen((data) { // You may also listen to all fields in one subscription
//      String id = data['id'];
//      String text = data['value'];
//      if (id == ID_EMAIL_INPUT) {
//        setState(() {
//          _emailController.value = TextEditingValue(text: text, selection: TextSelection.fromPosition(TextPosition(offset: text.length)));
//        });
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Screen'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (!commited) {
            await FlutterAutofill.cancel();
          }
          return true;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Dummy input to lose focus from other fields", hasFloatingPlaceholder: false, border: UnderlineInputBorder()),
                  style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 52.0),
                child: TextField(
                  focusNode: _emailFocus,
                  key: _emailKey,
                  controller: _emailController,
                  decoration:
                      InputDecoration(hintText: "Please enter your email", hasFloatingPlaceholder: false, border: UnderlineInputBorder()),
                  style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 52.0),
                child: TextField(
                  focusNode: _phoneNumFocus,
                  key: _phoneNumKey,
                  controller: _phoneNumController,
                  decoration:
                      InputDecoration(hintText: "Please enter your phone number", hasFloatingPlaceholder: false, border: UnderlineInputBorder()),
                  style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 52.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      focusNode: _ccNumFocus,
                      key: _ccNumKey,
                      controller: _ccNumController,
                      decoration:
                          InputDecoration(hintText: "Please enter your card number", hasFloatingPlaceholder: false, border: UnderlineInputBorder()),
                      style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                    TextField(
                      focusNode: _ccExpDateFocus,
                      key: _ccExpDateKey,
                      controller: _ccExpDateController,
                      decoration: InputDecoration(
                          hintText: "Please enter your card exp. date", hasFloatingPlaceholder: false, border: UnderlineInputBorder()),
                      style: Theme.of(context).textTheme.body1.copyWith(fontSize: 18),
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: RaisedButton(child: Text("Submit"), onPressed: _onSubmit),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumFocus.dispose();
    _emailFocus.dispose();
    _phoneNumController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FlutterAutofill.commit();
    commited = true;
    Navigator.pop(context);
    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => CompleteScreen()));
  }
}
