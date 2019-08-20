part of flutter_autofill;

class FlutterAutofill {
  static const MethodChannel _channel = const MethodChannel('flutter_autofill');
  static StreamController _textStreamController = StreamController.broadcast();
  static bool _registeredTextListener = false;

  static const _AF_CHANNEL = "AF_CHANNEL";

  static const AUTOFILL_TYPE_NONE = 0;
  static const AUTOFILL_TYPE_TEXT = 1;
  static const AUTOFILL_TYPE_TOGGLE = 2;
  static const AUTOFILL_TYPE_LIST = 3;
  static const AUTOFILL_TYPE_DATE = 4;

  static const AUTOFILL_HINT_EMAIL_ADDRESS = "emailAddress";
  static const AUTOFILL_HINT_NAME = "name";
  static const AUTOFILL_HINT_USERNAME = "username";
  static const AUTOFILL_HINT_PASSWORD = "password";
  static const AUTOFILL_HINT_PHONE = "phone";
  static const AUTOFILL_HINT_POSTAL_ADDRESS = "postalAddress";
  static const AUTOFILL_HINT_POSTAL_CODE = "postalCode";
  static const AUTOFILL_HINT_CREDIT_CARD_NUMBER = "creditCardNumber";
  static const AUTOFILL_HINT_CREDIT_CARD_SECURITY_CODE = "creditCardSecurityCode";
  static const AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_DATE = "creditCardExpirationDate";
  static const AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_MONTH = "creditCardExpirationMonth";
  static const AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_YEAR = "creditCardExpirationYear";
  static const AUTOFILL_HINT_CREDIT_CARD_EXPIRATION_DAY = "creditCardExpirationDay";

  static Stream<dynamic> get textStream {
    return _textStreamController.stream;
  }

  static Future<Stream<dynamic>> registerWidget(
      BuildContext context, String id, FocusNode focusNode, GlobalKey key, List<String> autofillHints, int autofillType,
      {bool editable = true, bool sensitiveData = true}) async {
    if (!Platform.isAndroid) {
      return null;
    }
    _registerTextListenerIfNeeded();
    focusNode.addListener(() {
      _updateWidgetCoordinates(context, id, key);
      _notifyWidgetFocus(id, focusNode.hasFocus);
    });
    await _channel.invokeMethod('registerWidget', {
      "id": id,
      "autofill_hints": autofillHints,
      "autofill_type": autofillType,
      "editable": editable,
      "sensitive_data": sensitiveData,
    });
    await _updateWidgetCoordinates(context, id, key);
    return _textStreamController.stream.where((data) => data["id"] == id).map((data) => data["value"]);
  }

  static Future<void> cancel() async {
    await _channel.invokeMethod('cancel');
  }

  static Future<void> commit() async {
    await _channel.invokeMethod('commit');
  }

  static Future<bool> _updateWidgetCoordinates(BuildContext context, String id, GlobalKey key) async {
    if (key.currentState?.mounted != true) {
      return false;
    }
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    RenderBox renderBox = key.currentContext.findRenderObject();
    if (renderBox == null || !renderBox.hasSize) {
      return false;
    }
    Offset position = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;
    Offset topLeft = size.topLeft(position);
    Offset bottomRight = size.bottomRight(position);
    double top = topLeft.dy * devicePixelRatio;
    double left = topLeft.dx * devicePixelRatio;
    double bottom = bottomRight.dy * devicePixelRatio;
    double right = bottomRight.dx * devicePixelRatio;
    bool result = await _channel.invokeMethod('updateWidgetCoordinates', {
      "id": id,
      "coordinates": {
        "top": top,
        "left": left,
        "bottom": bottom,
        "right": right,
      }
    });
    debugPrint('Updated coords of widget: $id');
    return result;
  }

  static Future<void> _notifyWidgetFocus(String id, bool focused) async {
    return await _channel.invokeMethod('notifyFocus', {
      "id": id,
      "focused": focused,
    });
  }

  static void _registerTextListenerIfNeeded() {
    if (!_registeredTextListener) {
      defaultBinaryMessenger.setMessageHandler(_AF_CHANNEL, (ByteData message) async {
        final buffer = message.buffer;
        final decodedStr = utf8.decode(buffer.asUint8List());
        var decodedJSON = jsonDecode(decodedStr);
        _textStreamController.add(decodedJSON);
        return null;
      });
      _registeredTextListener = true;
    }
  }
}
