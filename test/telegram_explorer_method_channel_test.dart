import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_explorer/telegram_explorer_method_channel.dart';

void main() {
  MethodChannelTelegramExplorer platform = MethodChannelTelegramExplorer();
  const MethodChannel channel = MethodChannel('telegram_explorer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
