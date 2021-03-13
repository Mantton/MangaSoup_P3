import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/downloads/models/task_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class DownloadQueue extends StatefulWidget {
  @override
  _DownloadQueueState createState() => _DownloadQueueState();
}

class _DownloadQueueState extends State<DownloadQueue> {
  //Variables
  ReceivePort _port = ReceivePort(); // Receiving port for download Isolate

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('ms_download_send_port');
    send.send([id, status, progress]); // Send Event
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'ms_download_send_port');
    if (!isSuccess) {
      // Failed to bind
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      print("Failed to connect");
      return;
    }
    _port.listen((dynamic data) {
      /*
      * Receives event in for of list [taskId, status, progress]
      * */

      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      TaskInfo task = TaskInfo(taskId: id);
      task.status = status;
      task.progress = progress;
      Provider.of<DatabaseProvider>(context, listen: false)
          .monitorDownloads(task);
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('ms_download_send_port');
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (context, db, _) {
      // Sort
      Map<int, List<ChapterDownload>> sorted = groupBy(
          db.chapterDownloads.where((element) => element.status != 3),
          (ChapterDownload obj) => obj.comicId); // Group Comic
      List<int> keys = sorted.keys.toList();
      return Container(
        child: ListView.separated(
            itemBuilder: (_, index) => ExpansionTile(
                  title: Text(
                    db.comics.firstWhere((e) => e.id == keys[index]).title,
                  ),
                  subtitle: Text(
                    db.comics.firstWhere((e) => e.id == keys[index]).source,
                  ),
                  children: List.generate(
                    sorted[keys[index]].length,
                    (i) => ListTile(
                      title: Text(db.chapters
                          .firstWhere(
                              (e) => e.id == sorted[keys[index]][i].chapterId)
                          .title),
                      trailing: CircularPercentIndicator(
                        radius: 45.0,
                        lineWidth: 3.0,
                        percent: sorted[keys[index]][i].progress / 100,
                        progressColor: Colors.purple,
                        backgroundColor: Colors.grey[900],
                        // fillColor: Colors.grey[900],
                      ),
                      onTap: () => print(sorted[keys[index]][i].status),
                    ),
                  ),
                ),
            separatorBuilder: (_, index) => SizedBox(
                  height: 7,
                ),
            itemCount: keys.length),
      );
    });
  }
}
