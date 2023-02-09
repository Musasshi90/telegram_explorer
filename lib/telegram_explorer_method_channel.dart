import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:telegram_explorer/file_item.dart';

import 'telegram_explorer_platform_interface.dart';

/// An implementation of [TelegramExplorerPlatform] that uses method channels.
class MethodChannelTelegramExplorer extends TelegramExplorerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('telegram_explorer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getFileItem() async {
    final version = await methodChannel.invokeMethod<String>('getFileItem');
    return version;
  }

  @override
  Future<String?> openDirectory(FileItem fileItem) async {
    Map params = <String, dynamic>{
      'fileItem': json.encode(fileItem.toJson()),
    };
    final version = await methodChannel.invokeMethod<String>('openDirectory', params);
    return version;
  }

  @override
  Future<String?> openBrowser() async {
    final version = await methodChannel.invokeMethod<String>('openBrowser', null);
    return version;
  }
}
