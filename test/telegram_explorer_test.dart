import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_explorer/file_item.dart';
import 'package:telegram_explorer/telegram_explorer.dart';
import 'package:telegram_explorer/telegram_explorer_platform_interface.dart';
import 'package:telegram_explorer/telegram_explorer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTelegramExplorerPlatform
    with MockPlatformInterfaceMixin
    implements TelegramExplorerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getFileItem() {
   return Future.value('41');
  }

  @override
  Future<String?> openDirectory(FileItem fileItem) {
    // TODO: implement openDirectory
    return Future.value('43');
  }
}

void main() {
  final TelegramExplorerPlatform initialPlatform = TelegramExplorerPlatform.instance;

  test('$MethodChannelTelegramExplorer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTelegramExplorer>());
  });

  test('getPlatformVersion', () async {
    TelegramExplorer telegramExplorerPlugin = TelegramExplorer();
    MockTelegramExplorerPlatform fakePlatform = MockTelegramExplorerPlatform();
    TelegramExplorerPlatform.instance = fakePlatform;

    expect(await telegramExplorerPlugin.getPlatformVersion(), '42');
  });
}
