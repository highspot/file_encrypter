#import "FileEncrypterPlugin.h"
#if __has_include(<file_encrypter/file_encrypter-Swift.h>)
#import <file_encrypter/file_encrypter-Swift.h>
#else
#import "file_encrypter-Swift.h"
#endif

@implementation FileEncrypterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFileEncrypterPlugin registerWithRegistrar:registrar];
}
@end
