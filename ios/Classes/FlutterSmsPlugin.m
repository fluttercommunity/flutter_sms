#import "FlutterSmsPlugin.h"

#if __has_include(<flutter_sms/flutter_sms-Swift.h>)
#import <flutter_sms/flutter_sms-Swift.h>
#else
// Fallback import
@import flutter_sms;
#endif

@implementation FlutterSmsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftFlutterSmsPlugin registerWithRegistrar:registrar];
}

@end