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
  String chapterUrl;
  int comicId;
  int chapterId;
  double progress;
  int status;

  ChapterDownload({this.chapterId, this.comicId}) {
    taskIds = [];
    progress = 0;
    status = 0; // waiting image request
    links = [];
  }
}

/*
* Statuses
* 0 - Waiting image request
* 1 - requesting image
* 2 - downloaidng
* 3 - done
* 4 - error
* 5
* 6
* 7
* 8
* 9
* */
