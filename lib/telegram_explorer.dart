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
      Directory appDocDir = await getApplicationDocumentsDirectory();
      list.add(FileItem(
          title: 'Application Documents',
          description: 'Browse application documents',
          path: appDocDir.path,
          isFolder: true,
          extension: '',
          isStorage: false,
          fileSize: 0,
          isRecentFile: false));
      Directory? downloadDir = await getDownloadsDirectory();
      if (downloadDir != null) {
        list.add(FileItem(
            title: 'Downloads',
            description: 'Browse downloads',
            path: downloadDir.path,
            isFolder: true,
            extension: '',
            isStorage: false,
            fileSize: 0,
            isRecentFile: false));
      }
      return list;
    }
  }

  Future<FileItem?> openDirectory(FileItem fileItem) async {
    return FileItem.getFileItem(
        await TelegramExplorerPlatform.instance.openDirectory(fileItem));
  }
}
