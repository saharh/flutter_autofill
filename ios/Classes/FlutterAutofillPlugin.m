#import "FlutterAutofillPlugin.h"
#import <flutter_autofill/flutter_autofill-Swift.h>

@implementation FlutterAutofillPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAutofillPlugin registerWithRegistrar:registrar];
}
@end
