#import "FileEncrypterPlugin.h"

@implementation FileEncrypterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFileEncrypterPlugin registerWithRegistrar:registrar];
}
@end
