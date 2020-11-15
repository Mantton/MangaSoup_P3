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
          double fP = p / (chapterPointer.tasks.length);
          chapterPointer.progress = fP.round();

          if (chapterPointer.progress == 0) {
            chapterPointer.status = "Queued";
          } else if (chapterPointer.progress < 100) {
            chapterPointer.status = "Downloading";
          } else if (fP == 100.0) {
            // If progress is exactly 100
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

  debugClear() async {
    downloads.clear();
    var tasks = await FlutterDownloader.loadTasks();
    for (var task in tasks) {
      FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: true);
    }
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

  /// LoadAll
  load() async {
    final tasks = await FlutterDownloader.loadTasks();

    for (var task in tasks) {
      print(task.status);
    }
  }

  /// Pause
  pauseAll() {
    List<ChapterDownloadObject> chapters = downloads
        .where((element) => element.status.contains("Download"))
        .toList();
    for (ChapterDownloadObject chapter in chapters) {
      pauseDownload(chapter);
    }
  }

  pauseDownload(ChapterDownloadObject chapter) {
    for (DownloadInfo task in chapter.tasks) {
      FlutterDownloader.pause(taskId: task.taskId);
    }
    chapter.status = "Paused";
    notifyListeners();
  }

  /// Resume
  resumeAll() {
    List<ChapterDownloadObject> chapters =
        downloads.where((element) => element.status.contains("Pause")).toList();

    for (ChapterDownloadObject chapter in chapters) {
      resumeDownload(chapter);
    }
  }

  resumeDownload(ChapterDownloadObject chapter) async {
    for (DownloadInfo task in chapter.tasks) {
      String newID = await FlutterDownloader.resume(taskId: task.taskId);

      /// Update Task ID's
      chapter
          .tasks[chapter.tasks
              .indexWhere((element) => element.taskId == task.taskId)]
          .taskId = newID;
    }
    chapter.status = "Downloading";
    notifyListeners();
  }

  /// Download
  download(ComicHighlight highlight, List chapters) async {
    for (Map map in chapters) {
      Chapter chapter = Chapter.fromMap(map);

      /// Fetch Image to ImageChapter object
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
            "${imageChapter.images.indexOf(image)}.${image
            .split(".")
            .last}";
        final taskId = await FlutterDownloader.enqueue(
          url: image,
          savedDir: newD.path,
          headers: {"referer": imageChapter.referer},
          fileName: fileName,
          showNotification: false,
          openFileFromNotification: false,
          requiresStorageNotLow: true,
        );

        /// Needed Lists
        imagesPaths.add(image);
        tasks.add(taskId);
        jet.add(DownloadInfo(taskId: taskId, filePath: fileName));
      }

      /// Create ChapterDownload Object.
      ChapterDownloadObject chapterDownload = ChapterDownloadObject(
        highlight: highlight,
        chapter: chapter,
        taskIDs: tasks,
        images: imagesPaths,
        tasks: jet,
      );

      /// Add object to list and notify listeners
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

  ChapterDownloadObject({
    this.highlight,
    this.chapter,
    this.taskIDs,
    this.images,
    this.tasks,
  });
}
