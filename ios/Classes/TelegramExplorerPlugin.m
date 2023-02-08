#import "TelegramExplorerPlugin.h"
#if __has_include(<telegram_explorer/telegram_explorer-Swift.h>)
#import <telegram_explorer/telegram_explorer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "telegram_explorer-Swift.h"
#endif

@implementation TelegramExplorerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTelegramExplorerPlugin registerWithRegistrar:registrar];
}
@end
