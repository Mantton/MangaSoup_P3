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
    status = MSDownloadStatus.queued; // waiting image request
    links = [];
  }
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
