import 'dart:convert';

import 'package:flutter_downloader/flutter_downloader.dart';

class TaskInfo {
  final String name;
  final String link;
  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  TaskInfo({this.name, this.link, this.taskId});
}

class ChapterDownload {
  int id;
  List<String> taskIds;
  List<String> links;
  String saveDir;
  String chapterUrl;
  int comicId;
  int chapterId;
  double progress;
  MSDownloadStatus status;
  int count;

  ChapterDownload({this.chapterId, this.comicId, this.saveDir}) {
    taskIds = [];
    progress = 0;
    count = 0;
    chapterUrl = "";
    saveDir = "";
    status = MSDownloadStatus.queued; // waiting image request
    links = [];
  }

  ChapterDownload.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    comicId = map['comic_id'];
    chapterId = map['chapter_id'];
    status = MSDownloadStatus.values
        .firstWhere((element) => element.index == map['status']);
    count = map['count'];
    progress = double.parse(map['progress']);
    chapterUrl = map['chapter_url'];
    saveDir = map['saved_dir'];
    taskIds = (jsonDecode(map['task_ids']) as List)
        ?.map((item) => item as String)
        ?.toList();
    links = (jsonDecode(map['image_links']) as List)
        ?.map((item) => item as String)
        ?.toList();
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "comic_id": comicId,
        "chapter_id": chapterId,
        "saved_dir": saveDir,
        "chapter_url": chapterUrl,
        "count": count,
        "progress": progress.toString(),
        "status": status.index,
        "task_ids": jsonEncode(taskIds),
        "image_links": jsonEncode(links),
      };
}

enum MSDownloadStatus {
  queued,
  requested,
  downloading,
  done,
  error,
}
/*
* Statuses
* 0 - Queued (Waiting image request)
* 1 - Requested (Requesting Image)
* 2 - Downloading (Request Successful, Downloading Chapter)
* 3 - Done / Complete (Download Successful, all images saved)
* 4 - Error / Request or Download Failed.
* */
