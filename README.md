# flutter_autofill

Provides [Android Autofill](https://developer.android.com/guide/topics/text/autofill) support for Flutter text fields.

Supports all Android [hint types](https://developer.android.com/reference/android/view/View.html#AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_DATE).

### Add dependency

```yaml
dependencies:
  flutter_autofill: ^0.4.0
```

## Usage

At its simplest form, you can just wrap your TextField with Autofill widget:

```dart
import 'package:flutter_autofill/flutter_autofill.dart';
```
```dart
          Autofill(
                onAutofilled: (val) {
                   // set value in controller & cursor position after auto-filled value
                  _emailController.value = TextEditingValue(text: val, selection: TextSelection.fromPosition(TextPosition(offset: val.length)));
                },
                autofillHints: [FlutterAutofill.AUTOFILL_HINT_EMAIL_ADDRESS],
                autofillType: FlutterAutofill.AUTOFILL_TYPE_TEXT,
                textController: _emailController,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "Please enter your email"),
                ),
              ),
```

For Autofill to function properly and be available on subsequent visits of screen, you must notify Autofill when data has been submitted or cancelled.
```dart
  bool commited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autofill Widget screen'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (!commited) {
            await FlutterAutofill.cancel();
          }
          return true;
        },
        child: ...
```

```dart
  void _onSubmit() async {
    await FlutterAutofill.commit();
    commited = true;
    ...
  }
```

