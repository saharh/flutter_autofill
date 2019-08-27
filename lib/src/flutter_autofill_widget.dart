part of flutter_autofill;

class Autofill extends StatefulWidget {
  final Widget child;
  final List<String> autofillHints;
  final ValueChanged<dynamic> onAutofilled;
  final int autofillType;
  final TextEditingController textController;

  Autofill(
      {@required this.child,
      @required this.autofillHints,
      @required this.onAutofilled,
      @required this.autofillType,
      this.textController});

  @override
  State<StatefulWidget> createState() => _AutofillState();
}

class _AutofillState extends State<Autofill> {
  static int incrementingID = 0;

  StreamSubscription _subscription;
  final GlobalKey _afKey = GlobalKey();
  final FocusNode _afFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _afFocus.dispose();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> init() async {
    if (!mounted) return;

    String id = 'af_widget${++incrementingID}';
    Stream stream = await FlutterAutofill.registerWidget(context, id, _afFocus,
        _afKey, widget.autofillHints, widget.autofillType,
        textController: widget.textController);
    _subscription = stream?.listen((afValue) {
      widget.onAutofilled(afValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(child: widget.child, focusNode: _afFocus, key: _afKey);
  }
}
