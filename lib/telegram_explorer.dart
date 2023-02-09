import 'dart:io';

import 'file_item.dart';
import 'telegram_explorer_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

class TelegramExplorer {
  Future<String?> getPlatformVersion() {
    return TelegramExplorerPlatform.instance.getPlatformVersion();
  }

  Future<List<FileItem>> getFileItem() async {
    FileItem gallery = FileItem(
        title: 'Gallery',
        description: 'Browse the gallery',
        path: '',
        isFolder: true,
        extension: '',
        isStorage: false,
        fileSize: 0,
        isGallery:true,
        isRecentFile: false);
    if (Platform.isAndroid) {
      List<FileItem> list = [];
      list.addAll(FileItem.getFileItemList(
          await TelegramExplorerPlatform.instance.getFileItem()));
      list.add(gallery);
      return list;
    } else {
      List<FileItem> list = [];
      list.add(gallery);
      list.add(FileItem(
          title: 'Select from files',
          description: 'Browse the files',
          path: "",
          isFolder: true,
          extension: '',
          isStorage: true,
          isIOSFileExplorer: true,
          fileSize: 0,
          isRecentFile: false));
      return list;
    }
  }

  Future<FileItem?> openDirectory(FileItem fileItem) async {
    return FileItem.getFileItem(
        await TelegramExplorerPlatform.instance.openDirectory(fileItem));
  }

  Future<String?> openIOSBrowser() async {
    return await TelegramExplorerPlatform.instance.openBrowser();
  }
}
