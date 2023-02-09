import 'dart:convert';

class FileItem {
  String? title;
  String? description;
  String? path;
  bool? isFolder;
  String? extension;
  bool? isRecentFile;
  bool? isStorage;
  int? fileSize;
  bool? isGallery;
  bool? isIOSFileExplorer;

  FileItem(
      {this.title,
        this.description,
        this.path,
        this.isFolder,
        this.extension,
        this.isStorage,
        this.fileSize,
        this.isGallery,
        this.isIOSFileExplorer,
        this.isRecentFile});

  FileItem.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    path = json['path'];
    isFolder = json['isFolder'];
    extension = json['extension'];
    isRecentFile = json['isRecentFile'];
    isStorage = json['isStorage'];
    isGallery = json['isGallery'];
    isIOSFileExplorer = json['isIOSFileExplorer'];
    fileSize = json['fileSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['path'] = path;
    data['isFolder'] = isFolder;
    data['extension'] = extension;
    data['isRecentFile'] = isRecentFile;
    data['isStorage'] = isStorage;
    data['fileSize'] = fileSize;
    data['isGallery'] = isGallery;
    data['isIOSFileExplorer'] = isIOSFileExplorer;
    return data;
  }

  static FileItem? getFileItem(dynamic response) {
    FileItem category;
    if (response is String) {
      if (response.isEmpty) return null;
      Map<String, dynamic> data = json.decode(response);
      category = FileItem.fromJson(data);
    } else {
      category = FileItem.fromJson(response);
    }
    return category;
  }

  static List<FileItem> getFileItemList(dynamic data) {
    if (data == null || data.isEmpty) return [];
    List<FileItem> list = [];
    if (data is List) {
      for (int i = 0; i < data.length; i++) {
        FileItem? outlet = getFileItem(data[i]);
        if (outlet != null) list.add(outlet);
      }
    } else if (data is String) {
      dynamic s = json.decode(data);
      if (s is String) {
        dynamic d = json.decode(s);
        if (d is List) {
          for (int i = 0; i < d.length; i++) {
            FileItem? item = getFileItem(d[i]);
            if (item != null) list.add(item);
          }
        }
      } else if (s is List) {
        for (int i = 0; i < s.length; i++) {
          FileItem? item = getFileItem(s[i]);
          if (item != null) list.add(item);
        }
      }
    }
    return list;
  }
}