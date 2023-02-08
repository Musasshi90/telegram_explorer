import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:telegram_explorer/file_item.dart';

import 'telegram_explorer_method_channel.dart';

abstract class TelegramExplorerPlatform extends PlatformInterface {
  /// Constructs a TelegramExplorerPlatform.
  TelegramExplorerPlatform() : super(token: _token);

  static final Object _token = Object();

  static TelegramExplorerPlatform _instance = MethodChannelTelegramExplorer();

  /// The default instance of [TelegramExplorerPlatform] to use.
  ///
  /// Defaults to [MethodChannelTelegramExplorer].
  static TelegramExplorerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TelegramExplorerPlatform] when
  /// they register themselves.
  static set instance(TelegramExplorerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getFileItem() {
    throw UnimplementedError('getFileItem() has not been implemented.');
  }

  Future<String?> openDirectory(FileItem fileItem) {
    throw UnimplementedError('openDirectory() has not been implemented.');
  }
}
