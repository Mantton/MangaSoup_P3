import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/variables.dart';
import 'package:path_provider/path_provider.dart';

class DownLoadsTesting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: TextButton(
          child: Text("Hello"),
          onPressed: () async {
            Directory tempDir = await getTemporaryDirectory();
            String tempPath = tempDir.path;

            Directory appDocDir = await getApplicationDocumentsDirectory();
            String appDocPath = appDocDir.path;
            String library =
                await getLibraryDirectory().then((value) => value.path);
            print(appDocPath);
            print(tempPath);
            print(library);

            String cacheDirectory = tempPath + "/libCachedImageData";
            print(cacheDirectory);
            print(dirStatSync(cacheDirectory));
          },
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> getCacheSize() async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  String cacheDirectory = tempPath + "/libCachedImageData";

  return dirStatSync(cacheDirectory);
}

Future<Map<String, dynamic>> getDownloadSize() async {
  Directory tempDir = await getApplicationDocumentsDirectory();
  String tempPath = tempDir.path;
  String cacheDirectory = tempPath + "/$msDownloadFolderName";
  return dirStatSync(cacheDirectory);
}

Map<String, dynamic> dirStatSync(String dirPath) {
  int fileNum = 0;
  int totalSize = 0;
  var dir = Directory(dirPath);
  try {
    if (dir.existsSync()) {
      dir
          .listSync(recursive: true, followLinks: false)
          .forEach((FileSystemEntity entity) {
        if (entity is File) {
          fileNum++;
          totalSize += entity.lengthSync();
        }
      });
    }
  } catch (e) {
    print(e.toString());
  }

  return {'count': fileNum, 'size': (totalSize / 1048576).round()};
}
