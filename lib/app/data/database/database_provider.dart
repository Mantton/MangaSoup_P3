import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/variables.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/mal_track_result.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/bookmark.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic-collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/downloads.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/history.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/track.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/bookmark_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/chapter_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic-collection_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/comic_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/download_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/history_queries.dart';
import 'package:mangasoup_prototype_3/app/data/database/queries/track_queries.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/services/track/myanimelist/mal_api_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'manager.dart';
import 'models/collection.dart';
import 'models/comic.dart';

class DatabaseProvider with ChangeNotifier {
  // Provider Variables
  List<Comic> comics = [];
  List<Collection> collections = [];
  List<History> historyList = [];
  List<ComicCollection> comicCollections = [];
  List<ChapterData> chapters = [];
  List<BookMark> bookmarks = [];
  List<Tracker> comicTrackers = [];
  List<ChapterDownload> chapterDownloads = [];
  Database _db;

  // Update Check Variable
  bool checkingForUpdates = false;

  // Query Managers
  ComicQuery comicManager;
  HistoryQuery historyManager;
  CollectionQuery collectionManager;
  ComicCollectionQueries comicCollectionManager;
  ChapterQuery chapterManager;
  BookMarkQuery bookmarkManager;
  TrackQuery trackerManager;
  DownloadQuery downloadManager;

  // init

  init() async {
    // Init Local DB
    _db = await DatabaseManager.initDB();
    comicManager = ComicQuery(_db);
    historyManager = HistoryQuery(_db);
    collectionManager = CollectionQuery(_db);
    comicCollectionManager = ComicCollectionQueries(_db);
    chapterManager = ChapterQuery(_db);
    bookmarkManager = BookMarkQuery(_db);
    trackerManager = TrackQuery(_db);
    downloadManager = DownloadQuery(_db);
    // Load Data into Provider Variables
    comics = await comicManager.getAll();
    collections = await collectionManager.getCollections();
    historyList = await historyManager.getHistory();
    comicCollections = await comicCollectionManager.getAll();
    chapters = await chapterManager.getAll();
    bookmarks = await bookmarkManager.getAllBookMarks();
    comicTrackers = await trackerManager.getTrackers();
    chapterDownloads = await downloadManager.getDownloads();
    var hangingDownloads = chapterDownloads
        .where((element) => element.status != MSDownloadStatus.done)
        .toList();
    print("Deleting ${hangingDownloads.length}");
    await deleteDownloads(hangingDownloads);
    print("Database Provider Successfully Initialized");
    notifyListeners();
  }

  // GENERATE COMIC
  Future<Map<String, dynamic>> generate(ComicHighlight highlight) async {
    ApiManager _manager = ApiManager();
    Map<String, dynamic> map = Map();

    /// Get Profile
    try {
      Profile profile = await _manager.getProfile(
        highlight.selector,
        highlight.link,
      );

      Comic generated = Comic(
        title: highlight.title,
        link: highlight.link,
        thumbnail: profile.selector != "hasu"
            ? profile.thumbnail
            : highlight.thumbnail,
        referer: highlight.imageReferer,
        source: highlight.source,
        sourceSelector: highlight.selector,
        chapterCount: profile.chapterCount ?? 0,
      );

      generated.unreadCount = generated.chapterCount;

      Comic comic = isComicSaved(generated);
      if (comic != null) {
        // UPDATE VALUES HERE
        if (profile.selector != "hasu") comic.thumbnail = profile.thumbnail;
        comic.updateCount = 0;
        comic.chapterCount = profile.chapterCount ?? 0;
        // GET UNREAD COUNT
        int t = chapters
            .where((element) => element.mangaId == comic.id && element.read)
            .length;
        comic.unreadCount = comic.chapterCount - t;
      } else
        comic = generated;

      // Evaluate
      int _id = await evaluate(comic);
      map = {"profile": profile, "id": _id};
    } catch (e) {
      ErrorManager.analyze(e);
    }
    return map;
  }

  updateUnread() {}

  /// COMICS
  Future<int> evaluate(Comic comic, {bool overWriteChapterCount = true}) async {
    // Updates OR Adds comics to db
    int id;
    try {
      Comic retrieved = isComicSaved(comic);

      if (retrieved == null) {
        // Save to Lib
        comic.dateAdded = DateTime.now();
        comic = await comicManager.addComic(comic);
        comics.add(comic);
      } else {
        // Update Comic Details
        comic.id = retrieved.id;
        comic.dateAdded = retrieved.dateAdded;
        if (!overWriteChapterCount) comic.chapterCount = retrieved.chapterCount;
        await comicManager.updateComic(comic);
        int index = comics.indexOf(retrieved);
        comics[index] = comic;
      }
      notifyListeners();
      id = comic.id;
    } catch (e) {
      ErrorManager.analyze(e);
    }
    return id;
  }

  List<Comic> searchLibrary(String query) {
    return comics
        .where(
          (element) =>
              element.inLibrary &&
              element.title.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
        )
        .toList();
  }

  Comic retrieveComic(int id) {
    return comics.firstWhere((element) => element.id == id);
  }

  Collection retrieveCollection(int id) {
    return collections.firstWhere((element) => element.id == id);
  }

  ChapterData retrieveChapter(int id) {
    return chapters.firstWhere((element) => element.id == id);
  }

  Comic isComicSaved(Comic comic) {
    try {
      Comic retrieved = comics.firstWhere((element) =>
          element.source == comic.source && comic.link == element.link);
      return retrieved;
    } catch (err) {
      return null;
    }
  }

  /// COLLECTIONS
  bool checkIfCollectionExists(String collectionName) {
    List<Collection> exists = collections
        .where((element) =>
            element.name.toLowerCase() == collectionName.toLowerCase())
        .toList();
    if (exists.isEmpty)
      return false;
    else
      return true;
  }

  clearAllCollection() async {
    // Delete Collections

    List<Collection> toDelete =
        collections.where((element) => element.id != 1).toList();
    collections.removeWhere(
        (element) => toDelete.contains(element)); // delete from provider object
    print(collections);
    print("Deleted Collections");
    // Delete Comic Collections
    List<ComicCollection> comicCollectionsToDelete = comicCollections
        .where((element) =>
            toDelete.map((e) => e.id).toList().contains(element.collectionId))
        .toList();
    comicCollections.removeWhere((element) =>
        comicCollectionsToDelete.contains(element)); // remove comic collections
    print("Deleted Comic Collections");
    // Delete from DB
    toDelete.forEach(
        (element) async => await collectionManager.deleteCollection(element));
    comicCollectionsToDelete.forEach((element) async =>
        await comicCollectionManager.deleteComicCollection(element));
    print("Updated Database");
    // Re-add Collections under default.
    Collection defaultCollection =
        collections.firstWhere((element) => element.id == 1);
    List<Comic> lib = comics.where((element) => element.inLibrary).toList();
    print("Retrieved favorites");
    lib.forEach((element) async =>
        await batchSetComicCollection([defaultCollection], element.id));
    print("Collection Clear Complete");
    notifyListeners();
  }

  updateCollectionOrder(List<Collection> toUpdate) {
    // Incoming list is sorted on the new order
    for (Collection c in toUpdate) {
      c.order = toUpdate.indexOf(c) + 1;
    }
    collections = toUpdate;
    collectionManager.reorderCollections(collections);
    notifyListeners();
  }

  Future<Collection> createCollection(String collectionName) async {
    Collection newCollection = Collection(name: collectionName.trim());
    newCollection.order = collections.length;
    newCollection = await collectionManager.addCollection(newCollection);
    collections.add(newCollection);
    print("Name: ${newCollection.name},Initial Order: ${newCollection.order}");
    notifyListeners();
    return newCollection;
  }

  Future<Collection> updateCollection(Collection collection) async {
    int index =
        collections.indexWhere((element) => element.id == collection.id);
    collections[index] = collection;
    await collectionManager.updateCollection(collection);
    notifyListeners();
    return collection;
  }

  // Comic Collections
  batchSetComicCollection(List<Collection> collections, int comicId) async {
    await comicCollectionManager.setCollectionsNonBatch(collections, comicId);
    comicCollections = await comicCollectionManager.getAll();
    notifyListeners();
  }

  /// Add to Library
  addToLibrary(List<Collection> collections, int comicId,
      {bool remove = false}) async {
    // Insert to Comic Collections
    batchSetComicCollection(collections, comicId);
    // Change status to in Library
    Comic retrieved = retrieveComic(comicId);
    retrieved.inLibrary = (!remove) ? true : false;
    await comicManager.updateComic(retrieved);
    int index = comics.indexOf(retrieved);
    comics[index] = retrieved;
    // Notify
    notifyListeners();
  }

  deleteFromLibrary(List<Comic> toDelete) async {
    // delete comic collections object
    // update comic collection database
    await comicCollectionManager.deleteForComic(toDelete);
    comicCollections = await comicCollectionManager.getAll();
    // update comic object

    // update comic database
    for (Comic comic in toDelete) {
      comic.inLibrary = false;
      comic.updateCount = 0;
      await comicManager.updateComic(comic);
      int pointer = comics.indexWhere((element) => element.id == comic.id);
      comics[pointer] = comic;
    }
    notifyListeners();
  }

  List<int> getSpecificComicCollectionIds(int comicId) {
    List<ComicCollection> retrieved = comicCollections
        .where((element) => element.comicId == comicId)
        .toList();
    return retrieved.map((e) => e.collectionId).toList();
  }

  List<Comic> getCollectionComics(int id) {
    // get the get comic collections matching given id;

    List<int> requiredIds = comicCollections
        .where((element) => element.collectionId == id)
        .toList()
        .map((e) => e.comicId)
        .toList();

    // get the comic linked to those collections

    List<Comic> requiredComics =
        comics.where((element) => requiredIds.contains(element.id)).toList();
    return requiredComics;
  }

  toggleCollectionUpdate(Collection collection) {
    collection.updateEnabled = !collection.updateEnabled;

    int target =
        collections.indexWhere((element) => element.id == collection.id);
    collections[target] = collection;
    collectionManager.updateCollection(collection);
    notifyListeners();
  }

  Future<int> checkForUpdates() async {
    debugPrint("--- CHECKING FOR UPDATE ---");
    checkingForUpdates = true;
    notifyListeners();
    int updateCount = 0;
    List<Collection> uec =
        collections.where((element) => element.updateEnabled).toList();

    if (uec.isEmpty) {
      debugPrint("---DONE CHECKING FOR UPDATE---");
      checkingForUpdates = false;
      notifyListeners();
      return null;
    }

    for (Collection c in uec) {
      List<ComicCollection> d = comicCollections
          .where((element) => element.collectionId == c.id)
          .toList();

      for (ComicCollection e in d) {
        Comic comic = comics.firstWhere((element) => element.id == e.comicId);
        // calculate if chapter count has increased
        /// CHECK FOR UPDATE LOGIC
        int currentChapterCount = comic.chapterCount;
        // Get Profile of comic

        try {
          Profile profile =
              await ApiManager().getProfile(comic.sourceSelector, comic.link);
          int updatedChapterCount = profile.chapterCount;

          // increase or do nothing about the updated count
          /// UPDATE COUNT LOGIC
          if (updatedChapterCount > currentChapterCount) {
            updateCount++; // increase update count metric
            // Update Comic Data
            comic.chapterCount = updatedChapterCount;
            comic.updateCount = updatedChapterCount - currentChapterCount;
          }

          // GET UNREAD COUNT
          int t = chapters
              .where((element) => element.mangaId == comic.id && element.read)
              .length;
          comic.unreadCount = comic.chapterCount - t;
          await evaluate(comic);
        } catch (e) {
          continue;
        }
      }
    }
    print("---DONE CHECKING FOR UPDATE---");
    checkingForUpdates = false;
    notifyListeners();
    return updateCount;
  }

  clearUpdates(List<Comic> toClear) async {
    List<Comic> targets =
        toClear.where((element) => element.updateCount > 0).toList();

    for (Comic comic in targets) {
      int pointer = comics.indexWhere((element) => element.id == comic.id);
      comics[pointer].updateCount = 0;
      comic.updateCount = 0;
      await comicManager.updateComic(comic);
    }
    notifyListeners();
  }

  ChapterData checkIfChapterMatch(Chapter chapter) {
    ChapterData implied;
    try {
      implied = chapters.firstWhere((element) =>
          element.generatedChapterNumber == chapter.generatedNumber &&
          element.link == chapter.link);
      return implied;
    } catch (err) {
      return null;
    }
  }

  updateChapterImages(Chapter chapter, List images) async {
    ChapterData data = checkIfChapterMatch(chapter);
    if (data != null) {
      data.images = images;
      int d = chapters.indexWhere((element) => element.id == data.id);
      chapters[d] = data;
      await chapterManager.updateBatch([data]);
      notifyListeners();
    }
  }

  bool checkSimilarRead(Chapter chapter, int comicId) {
    bool check = chapters.any((element) =>
        element.read &&
        element.generatedChapterNumber == chapter.generatedNumber &&
        element.mangaId == comicId);
    return check;
  }

  updateFromACS(List<Chapter> incoming, int comicId, bool read, String source,
      String selector,
      {bool toggleRead = true}) async {
    List<ChapterData> data = [];
    // Check for matches, update their status to read then add to data
    for (Chapter chapter in incoming) {
      ChapterData append = checkIfChapterMatch(chapter);
      // Check for non matches Create nChapterData objects then append to data
      if (append == null) {
        append = ChapterData(
          title: chapter.name,
          mangaId: comicId,
          link: chapter.link,
          generatedChapterNumber: chapter.generatedNumber,
          source: source,
          selector: selector,
        );
      }
      if (toggleRead) append.read = read;
      data.add(append);
    }
    data = await chapterManager.updateBatch(data);
    // if in chapters, update
    for (ChapterData obj in data) {
      if (chapters.any((element) => element.id == obj.id))
        chapters[chapters.indexWhere((element) => element.id == obj.id)] = obj;
      else
        chapters.add(obj);
    }

    // UPDATE COMIC UNREAD COUNT
    Comic c = comics.firstWhere((element) => element.id == comicId);
    int t = chapters
        .where((element) => element.mangaId == c.id && element.read)
        .length;
    if (c.chapterCount == t)
      c.unreadCount = 0;
    else
      c.unreadCount = c.chapterCount - t;
    await evaluate(c);
    notifyListeners();
    // MD Sync
    if (selector == "mangadex" && read) {
      SharedPreferences.getInstance().then((_prefs) async {
        if (_prefs.getString("mangadex_cookies") != null) {
          // Cookies containing profile exists
          // Sync to MD
          try {
            ApiManager().syncChapters(data.map((e) => e.link).toList(), true);
          } catch (err) {
            showSnackBarMessage(err);
          }
        }
      });
    }
  }

  Future<void> updateChapterInfo(int page, Chapter chapter) async {
    ChapterData data = checkIfChapterMatch(chapter);
    data.lastPageRead = page;
    int d = chapters.indexWhere((element) => element.id == data.id);
    chapters[d] = data;
    // notifyListeners();
    await chapterManager.updateBatch([data]);
  }

  Future<void> updateHistoryFromChapter(
      int comicId, Chapter chapter, int page) async {
    updateChapterInfo(page, chapter).then((value) async {
      ChapterData pointed = checkIfChapterMatch(chapter);
      await updateHistory(comicId, pointed.id);
    });
  }

  Future<void> updateHistory(int comicId, int chapterId) async {
    if (historyList.any((element) => element.comicId == comicId)) {
      int targetIndex =
          historyList.indexWhere((element) => element.comicId == comicId);

      historyList[targetIndex].chapterId = chapterId;
      historyList[targetIndex].lastRead = DateTime.now();

      await historyManager.updateHistory(historyList[targetIndex]);
      // update
    } else {
      // add
      History newHistory = History(comicId: comicId, chapterId: chapterId);
      newHistory = await historyManager.addHistory(newHistory);
      historyList.add(newHistory);
    }

    notifyListeners();
  }

  Future<void> removeHistory(History history) async {
    await historyManager.deleteHistory(history);
    historyList.remove(history);
    notifyListeners();
  }

  clearHistory() async {
    for (History h in historyList) {
      await historyManager.deleteHistory(h);
    }
    historyList.clear();
    notifyListeners();
  }

  historyLogic(
      Chapter chapter, int comicId, String source, String selector) async {
    ChapterData data = checkIfChapterMatch(chapter);
    if (data == null) {
      await updateFromACS([chapter], comicId, false, source, selector);
      data = checkIfChapterMatch(chapter);
    }
    await updateHistory(comicId, data.id);
  }

  addBookmark(BookMark mark) async {
    mark = await bookmarkManager.addBookMark(mark);
    bookmarks.add(mark);
    print("bookmark added");
    notifyListeners();
  }

  deleteBookMark(BookMark mark) async {
    await bookmarkManager.deleteBookMark(bookmarks.firstWhere((element) =>
        element.page == mark.page && element.chapterLink == mark.chapterLink));

    bookmarks.removeWhere((element) => element.id == mark.id);
    print("bookmark deleted");
    notifyListeners();
  }

  toggleBookMark(BookMark mark) async {
    if (checkIfBookMarked(mark)) {
      await deleteBookMark(mark);
    } else
      await addBookmark(mark);
  }

  bool checkIfBookMarked(BookMark mark) {
    return bookmarks.any((element) =>
        element.page == mark.page && element.chapterLink == mark.chapterLink);
  }

  deleteCollection(Collection collection) async {
    // Get Comic collections where it matches
    List<ComicCollection> pointers = comicCollections
        .where((element) => element.collectionId == collection.id)
        .toList();

    for (ComicCollection pointer in pointers) {
      // Check if this is the only collection attributed to the comic
      if (comicCollections
              .where((element) => element.comicId == pointer.comicId)
              .length >
          1) {
        // Comic is in multiple collections, safe to delete
        comicCollections.remove(pointer);
        await comicCollectionManager.deleteComicCollection(pointer);
      } else {
        // Move Comic to default.
        pointer.collectionId = 1;
        int target =
            comicCollections.indexWhere((element) => element.id == pointer.id);
        comicCollections[target] = pointer;
        await comicCollectionManager.updateComicCollection(pointer);
      }
    }

    // Delete from Provider Object
    collections.removeWhere((element) => element.id == collection.id);
    await collectionManager.deleteCollection(collection);
    notifyListeners();
  }

  /// TRACKER
  addTracker(var result, int comicID) async {
    Tracker tracker = Tracker(comicId: comicID);
    print("$comicID is the incoming comic id");
    tracker.comicId = comicID;

    if (result is MALDetailedTrackResult) {
      print("MAL TRACKER");
      MALDetailedTrackResult r = result;
      // MY ANIME LIST
      tracker.trackerType = 2; // 2 for MAL
      tracker.title = r.title;
      tracker.mediaId = r.id;
      tracker.totalChapters = r.chapterCount;
      if (r.userStatus != null) {
        tracker.lastChapterRead = r.userStatus.chaptersRead;
        tracker.status = getMALStatus(r.status);
        tracker.score = r.userStatus.score;

        try {
          tracker.dateEnded = DateTime.parse(r.userStatus.endDate);
          tracker.dateStarted = DateTime.parse(r.userStatus.startDate);
        } catch (err) {}
      } else {
        tracker.status = MALTrackStatus.reading;
      }
    }
    print("saving & adding");
    tracker = await trackerManager.addTracker(tracker);
    comicTrackers.add(tracker);
    notifyListeners();
    print("done");
    print(tracker.toMap());
  }

  Future<void> deleteTracker(Tracker tracker) async {
    await trackerManager.deleteTracker(tracker);
    comicTrackers.remove(tracker);
    notifyListeners();
  }

  Future<void> updateTracker(Tracker tracker) async {
    if (tracker.trackerType == 2) {
      /// MAL
      try {
        // API UPDATE
        await MALManager().updateTracker(tracker);
        trackerManager.updateTracker(tracker);
        int target =
            comicTrackers.indexWhere((element) => element.id == tracker.id);
        comicTrackers[target] = tracker;
        notifyListeners();
      } catch (err) {
        ErrorManager.analyze(err);
      }
    }
  }

  Future<void> deleteAllTrackers() async {
    for (Tracker t in comicTrackers) {
      await trackerManager.deleteTracker(t);
    }
    comicTrackers.clear();
  }

  Future<ComicHighlight> migrateComic(ComicHighlight c, Profile d) async {
    // the process really is a waste
    // get Comics for the profiles
    Comic current = comics.firstWhere((element) => element.link == c.link);
    Comic destination = comics.firstWhere((element) => element.link == d.link);

    /// Chapters
    // Get all Read chapters for current, create new chapter objects for d
    List<double> readChapters = chapters
        .where((element) => element.mangaId == current.id && element.read)
        .map((e) => e.generatedChapterNumber)
        .toSet()
        .toList();
    // list above contains the generated numbers for all read chapters in the lib
    List<Chapter> toMark = [];
    toMark = d.chapters
        .where((element) => readChapters.contains(element.generatedNumber))
        .toList();
    await updateFromACS(toMark, destination.id, true, destination.source,
        destination.sourceSelector);
    // Status
    current.inLibrary = false;
    destination.inLibrary = true;
    List<int> ids = comicCollections
        .where((element) => element.comicId == current.id)
        .map((e) => e.collectionId)
        .toList();
    List<Collection> targetCollections =
        collections.where((element) => ids.contains(element.id)).toList();
    await batchSetComicCollection([], current.id);
    await batchSetComicCollection(targetCollections, destination.id);
    // Tracking
    // todo, move tracking.
    var trackers =
        comicTrackers.where((element) => element.comicId == current.id);
    for (var T in trackers) {
      T.comicId = destination.id;
      await updateTracker(T);
    }

    // Update Comic
    int i1 = comics.indexOf(current);
    int i2 = comics.indexOf(destination);
    comics[i1] = current;
    comics[i2] = destination;

    await comicManager.updateComic(current);
    await comicManager.updateComic(destination);

    notifyListeners();
    return destination.toHighlight();
  }

  /// --------------  DOWNLOADING  ------------------ ///

  void downloadChapters(List<Chapter> toDownload, int comicId, String source,
      String selector, var platform) async {
    // Download path stuff
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    // Create a download object
    await updateFromACS(toDownload, comicId, false, source, selector,
        toggleRead: false);
    List<ChapterDownload> newDownloads = [];
    for (Chapter chapter in toDownload) {
      // Get the ChapterData object
      if (chapter.openInBrowser) continue;
      ChapterData pointer = checkIfChapterMatch(chapter);
      ChapterDownload c;
      if (pointer != null) {
        if (chapterDownloads.any((element) => element.chapterId == pointer.id))
          continue;
        else {
          c = ChapterDownload(chapterId: pointer.id, comicId: comicId);
          c.chapterUrl = chapter.link;
          newDownloads.add(c);
        }
      }
    }
    //Save to DB
    for (var x in newDownloads) {
      x = await downloadManager.addDownload(x);
    }
    chapterDownloads.addAll(newDownloads);
    notifyListeners(); // Show Queue indicator
    Comic cm = comics.firstWhere((element) => element.id == comicId);

    for (ChapterDownload download in newDownloads) {
      // Try to get Images
      ChapterData chapterData =
          chapters.firstWhere((element) => element.id == download.chapterId);

      try {
        download.status = MSDownloadStatus.requested;
        String filePath =
            "/$msDownloadFolderName/$source/${cm.title}/${chapterData.title}-${chapterData.id}/";
        String _localPath = directory.path + filePath;
        download.saveDir = filePath;
        notifyListeners(); // Notify of Status Change
        await downloadManager.updateDownload(download);
        ImageChapter value =
            await ApiManager().getImages(selector, download.chapterUrl);
        // Update ChapterData
        if (value.images.isNotEmpty) {
          chapterData.images = value.images;
          await chapterManager.updateBatch([chapterData]);
        }

        // Update Status
        // Queuing tasks
        download.count = value.images.length;
        // Create Download Path
        Directory savedDir =
            await Directory(_localPath).create(recursive: true);
        // Download Logic
        print("Downloading ${chapterData.title}, ${download.count} Images");
        Map<String, String> headers = Map();
        if (value.referer != null || value.referer.isNotEmpty)
          headers = {"referer": value.referer};
        download.status = MSDownloadStatus.downloading;
        notifyListeners();

        /// Queue Images
        for (String image in value.images) {
          String returnedTaskId = await FlutterDownloader.enqueue(
            url: image,
            savedDir: savedDir.path,
            fileName: "${value.images.indexOf(image)}.jpg",
            requiresStorageNotLow: true,
            headers: headers,
          );
          download.taskIds.add(returnedTaskId);
        }
      } catch (err) {
        download.status = MSDownloadStatus.error;
        notifyListeners();
        print("Caught Error");
      }
      // Update DB
      await downloadManager.updateDownload(download);
    }
  }

  Future<void> deleteDownloads(List toDelete) async {
    List<ChapterDownload> targets = [];
    if (toDelete is List<Chapter>) {
      for (Chapter chapter in toDelete) {
        // Get the ChapterData object
        ChapterData pointer = checkIfChapterMatch(chapter);

        if (pointer != null) {
          var x = chapterDownloads.firstWhere((e) => e.chapterId == pointer.id,
              orElse: () => null);
          if (x != null) targets.add(x);
        }
      }
    } else if (toDelete is List<ChapterDownload>) {
      targets = List.of(toDelete);
    }
    // Delete Object so
    chapterDownloads.removeWhere((e) => targets.contains(e));
    // Delete all tasks associated with chapter, then delete object
    var directory = await getApplicationDocumentsDirectory();
    print("Deleting ${targets.length} downloads.");
    for (ChapterDownload download in targets) {
      await downloadManager.deleteDownload(download);
      List ids = download.taskIds;
      for (var id in ids) {
        await FlutterDownloader.remove(taskId: id, shouldDeleteContent: true);
      }

      if (download.saveDir.isNotEmpty) {
        String path = directory.path + download.saveDir;
        try {
          Directory(path).deleteSync(recursive: true);
        } catch (err) {
          showSnackBarMessage("Dangling Downloads Uncleared", error: true);
        }
      }
    }
    notifyListeners();
  }

  void monitorDownloads(TaskInfo task) async {
    // This essentially monitors the callback and syncs the task with the db
    // Get ChapterDownload to be updated
    ChapterDownload c = chapterDownloads.firstWhere(
        (element) => element.taskIds.contains(task.taskId),
        orElse: () => null);

    if (c != null) {
      if (task.status != DownloadTaskStatus.failed) {
        // Task has not failed

        // Update progress
        List<DownloadTask> pointers = [];
        String test =
            "(${c.taskIds.map((e) => "'${e.toString()}\'").join(", ")})";
        String query = "SELECT * FROM task WHERE task_id IN $test";
        pointers = await FlutterDownloader.loadTasksWithRawQuery(query: query);

        if (task.status == DownloadTaskStatus.complete) {
          var t =
              pointers.firstWhere((element) => element.taskId == task.taskId);
          String fil = c.saveDir + t.filename;

          if (!c.links.contains(fil)) {
            c.links.add(fil);
          }
        }

        if (c.progress != 100.0) {
          int taskProgress =
              pointers.map((e) => e.progress).toList().fold(0, (p, c) => p + c);
          c.progress = taskProgress / c.count;
          // print("${c.chapterId}: ${c.progress}, $taskProgress");
          // if (c.progress == 100) print("Complete : ${c.chapterId}");
          // print(query);
        } else {
          if (c.progress == 100.0 &&
              c.links.length == c.count &&
              c.count == c.taskIds.length) {
            c.status = MSDownloadStatus.done;
            c.links.sort((a, b) => parsePageNum(a).compareTo(parsePageNum(b)));
            print("${c.chapterId}: Download Complete");
          }
        }
      } else {
        c.status = MSDownloadStatus.error;
      }
      await downloadManager.updateDownload(c);
      notifyListeners();
    }
  }

  parsePageNum(String page) {
    page = page.split("/").last;
    page = page.split(".").first;

    int p = int.parse(page);
    return p;
  }

  Future<void> retryDownload(BuildContext context) async {
    for (ChapterDownload download in chapterDownloads
        .where((element) => element.status == MSDownloadStatus.error)) {
      // CLear task id

      for (String task in download.taskIds) {
        await FlutterDownloader.remove(taskId: task, shouldDeleteContent: true);
        // await FlutterDownloader.cancel(taskId: task);
      }
      download.taskIds.clear();
      // Try to get Images
      ChapterData chapterData =
          chapters.firstWhere((element) => element.id == download.chapterId);
      try {
        download.status = MSDownloadStatus.requested;
        notifyListeners(); // Notify of Status Change
        ImageChapter value = await ApiManager()
            .getImages(chapterData.selector, download.chapterUrl);
        // Update ChapterData
        if (value.images.isNotEmpty) chapterData.images = value.images;

        // Update Status
        // Queuing tasks
        download.count = value.images.length;
        // Create Download Path

        String _localPath =
            Provider.of<PreferenceProvider>(context, listen: false).paths +
                download.saveDir;

        Directory savedDir =
            await Directory(_localPath).create(recursive: true);

        // Download Logic
        print("Downloading ${chapterData.title}, ${download.count} Images");
        // download.saveDir = filePath;
        Map<String, String> headers = Map();
        if (value.referer != null || value.referer.isNotEmpty)
          headers = {"referer": value.referer};
        download.status = MSDownloadStatus.downloading;
        notifyListeners();

        /// Queue Images
        for (String image in value.images) {
          String returnedTaskId = await FlutterDownloader.enqueue(
            url: image,
            savedDir: savedDir.path,
            fileName: "${value.images.indexOf(image)}.jpg",
            requiresStorageNotLow: true,
            headers: headers,
          );
          download.taskIds.add(returnedTaskId);
        }
      } catch (err) {
        download.status = MSDownloadStatus.error;
        notifyListeners();
      }
      // Update DB
      await downloadManager.updateDownload(download);
    }
  }

  Future<void> cancelDownload() async {
    List<ChapterDownload> toDelete = List.of(chapterDownloads
        .where((element) => element.status == MSDownloadStatus.error)
        .toList());
    for (ChapterDownload download in toDelete) {
      // CLear task id

      for (String task in download.taskIds) {
        await FlutterDownloader.remove(taskId: task, shouldDeleteContent: true);
        // await FlutterDownloader.cancel(taskId: task);
      }

      await downloadManager.deleteDownload(download);
      chapterDownloads.removeWhere((element) => element.id == download.id);
    }
    notifyListeners();
  }

  Future<void> deleteAllDownloads(BuildContext context) async {
    // Get path
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = directory.path + "/" + msDownloadFolderName + "/";
    String fix = directory.path + "/" + "MSDownload" + "/";
    Directory(path).createSync(recursive: true);
    await FlutterDownloader.cancelAll(); // Cancel All running tasks
    for (var d in chapterDownloads) {
      for (var task in d.taskIds) {
        await FlutterDownloader.remove(taskId: task);
      }
      await downloadManager.deleteDownload(d);
    }
    chapterDownloads.clear();
    // Delete Directory.
    Directory(path).deleteSync(recursive: true);
    Directory(path).createSync(recursive: true);
    notifyListeners();
  }

  Future<void> clearChapterDataInfo(List<Chapter> pointers) async {
    List<ChapterData> toUpdate = [];
    for (Chapter chapter in pointers) {
      // Get the ChapterData object
      ChapterData target = checkIfChapterMatch(chapter);

      // Reset Info
      if (target != null) {
        target.images.clear();
        target.lastPageRead = 1;

        //Update Info
        int d = chapters.indexWhere((element) => element.id == target.id);
        chapters[d] = target;
        toUpdate.add(target);
      }
    }
    await chapterManager.updateBatch(toUpdate);
    notifyListeners();
  }
}
