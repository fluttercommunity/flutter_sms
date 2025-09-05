#import "FlutterSmsPlugin.h"
#import <send_message/send_message-Swift.h>

@implementation FlutterSmsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSmsPlugin registerWithRegistrar:registrar];
}
@end
