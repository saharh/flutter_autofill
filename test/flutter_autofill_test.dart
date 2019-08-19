import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_autofill/flutter_autofill.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_autofill');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    expect(await FlutterAutofill.platformVersion, '42');
//  });
}
