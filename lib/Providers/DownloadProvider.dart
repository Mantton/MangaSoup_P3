import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:path_provider/path_provider.dart';

class DownloadProvider with ChangeNotifier {
  ReceivePort _port = ReceivePort();
  ApiManager _manager = ApiManager();
  List<ChapterDownloadObject> downloads = List();

  init() async {
    print("downloads Initializing");
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      print("listening...");
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      // print("$id, $status, $progress");
      if (downloads != null && downloads.isNotEmpty) {
        // final task = downloads.firstWhere((task) => task.taskId == id);
        final chapterPointer =
            downloads.firstWhere((element) => element.taskIDs.contains(id));
        final task =
            chapterPointer.tasks.firstWhere((element) => element.taskId == id);

        if (task != null) {
          task.status = status;
          task.progress = progress;
          int p = 0;
          for (DownloadInfo t in chapterPointer.tasks) {
            p += t.progress;
          }
          int fP = (p / (chapterPointer.tasks.length)).round();
          chapterPointer.progress = fP;

          if (chapterPointer.progress == 0) {
            chapterPointer.status = "Queued";
          } else if (chapterPointer.progress < 100) {
            chapterPointer.status = "Downloading";
          } else if (chapterPointer.progress == 100) {
            chapterPointer.status = "Done";
            // todo, save to downloads db directory
            // todo, create downloads db
            // todo, pause all and check for fail feature
          }
          notifyListeners();
        }
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  debugClear() {
    downloads.clear();
    notifyListeners();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  testDownload(ComicHighlight highlight, List chapters) async {
    print("Task Starting");
    await download(highlight, chapters);
  }

  download(ComicHighlight highlight, List chapters) async {
    for (Map map in chapters) {
      Chapter chapter = Chapter.fromMap(map);
      ImageChapter imageChapter =
          await _manager.getImages(highlight.selector, chapter.link);
      var dir = await getApplicationDocumentsDirectory();
      Directory downloadDirectory =
          await Directory("${dir.path}/Downloads").create();
      String path = "${downloadDirectory.path}/"
          "${highlight.selector}/"
          "${highlight.title}/"
          "${chapter.name}"
          "${(chapter.maker.isNotEmpty) ? "-${chapter.maker}" : ""}";

      Directory newD = await Directory(path).create(recursive: true);

      /// Add to Download Queue
      List<String> imagesPaths = List();
      List<String> tasks = List();
      List<DownloadInfo> jet = List();
      for (String image in imageChapter.images) {
        String fileName =
            "${imageChapter.images.indexOf(image)}.${image.split(".").last}";
        // print(123.toString().padLeft(10, '0'));
        final taskId = await FlutterDownloader.enqueue(
            url: image,
            savedDir: newD.path,
            headers: {"referer": imageChapter.referer},
            fileName: fileName);

        // Needed Lists
        imagesPaths.add(image);
        tasks.add(taskId);
        jet.add(DownloadInfo(taskId: taskId, filePath: fileName));
      }

      ChapterDownloadObject chapterDownload = ChapterDownloadObject(
        highlight: highlight,
        chapter: chapter,
        taskIDs: tasks,
        images: imagesPaths,
        tasks: jet,
      );
      // Save downloadObject
      // Add to List
      downloads.add(chapterDownload);
      notifyListeners();
    }
  }
}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}

class Test {
  final String name;
  final String path;
  List<_TaskInfo> tasks;
  int progress = 0;
  DownloadTaskStatus status;

  Test(this.name, this.path);
}

class DownloadInfo {
  String taskId;
  String filePath;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  DownloadInfo({this.taskId, this.filePath});
}

class ComicDownloadObject {
  ComicHighlight highlight;
}

class ChapterDownloadObject {
  final ComicHighlight highlight;
  final Chapter chapter;

  List<DownloadInfo> tasks;
  List<String> images;
  List<String> taskIDs;
  int progress = 0;
  String status = "Waiting";

  ChapterDownloadObject(
      {this.highlight, this.chapter, this.taskIDs, this.images, this.tasks});
}
