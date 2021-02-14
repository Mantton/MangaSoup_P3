import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/bookmark.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_view_holder.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/empty_response.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reached_end_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reader_transition_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderProvider with ChangeNotifier {
  int comicId;
  String source;
  bool showControls = false;

  List<ReaderChapter> readerChapters = List(); // loaded chapters
  List<Widget> widgetPageList = List(); // Pages to be shown
  List<Chapter> chapters = List(); // the chapters from the profile
  List pagePositionList = List(); // the page number for each widget page
  List indexList = List(); // the chapter index for each page

  int currentPage = 0;
  String selector;
  int currentIndex = 0;
  ChapterData currentChapter;
  int pageDisplayNumber = 1;
  int pageDisplayCount = 1;
  Map chapterHolder = Map();
  String currentChapterName = "";
  int lastPage;
  BuildContext context;
  bool reachedEnd = false;
  bool imgur = false;
  int initialPageIndex = 1;

  Future init(
      List<Chapter> incomingChapters,
      int initialIndex,
      String incomingSelector,
      BuildContext widgetContext,
      int comic_id,
      String incomingSource,
      {bool loaded = false,
      bool imgurAlbum = false,
      ImageChapter loadedChapter,
      int initPage = 1}) async {
    reset();
    // Create Starting values
    chapters = List.of(incomingChapters);
    currentIndex = initialIndex;
    selector = incomingSelector;
    context = widgetContext;
    comicId = comic_id;
    source = incomingSource;
    // Get Chapter being pointed to
    Chapter chapter = incomingChapters.elementAt(initialIndex);
    imgur = imgurAlbum;

    // prepare initial page
    initialPageIndex = initPage - 1;
    pageDisplayNumber = initPage;
    if (!imgur) {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .historyLogic(chapter, comicId, source, selector);
      print("History Initialized");
    }

    // Debugging
    print("Specified Initial Page Index: $initialPageIndex");
    // Initialize Reader Chapter
    ReaderChapter firstChapter = ReaderChapter();
    firstChapter.chapterName = chapter.name;
    firstChapter.generatedNumber = chapter.generatedNumber;
    firstChapter.index = initialIndex;

    ImageChapter response;
    try {
      // Get Images
      response = !loaded
          ? await ApiManager().getImages(selector, chapter.link)
          : loadedChapter;
    } catch (err) {
      ErrorManager.analyze(err);
    }

    try {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .updateChapterImages(chapter, response.images);
      print("Images set for ${chapter.name}");
      await Provider.of<DatabaseProvider>(context, listen: false)
          .updateChapterInfo(1, chapter);
    } catch (err) {
      print("IMAGE ERROR: $err");
    }
    if (response.images.isEmpty) {
      emptyResponse();
    } else {
      int c = 0;
      for (String uri in response.images) {
        ReaderPage newPage = ReaderPage(c + 1, uri, response.referer);
        firstChapter.pages.add(newPage);
        c++;
        pagePositionList.add(c);
        indexList.add(currentIndex);
      }
      // Add to View and Notify Listener
      addInitialChapterToView(firstChapter);
    }

    notifyListeners();
    return true;
  }

  addInitialChapterToView(ReaderChapter chapter) {
    /// This adds the initial ReaderChapter ReaderPages to the PageListView
    // Create Page Widgets, add to View

    for (ReaderPage page in chapter.pages) {
      Widget view = ImageHolder(
        page: page,
      );
      widgetPageList.add(view);
    }
    readerChapters.add(chapter);

    Map initialEntry = {chapter.index: chapter.pages.length};
    chapterHolder.addAll(initialEntry);
    pageDisplayCount = chapter.pages.length;
    currentChapterName = chapter.chapterName;

    // Initial BookMark
    BookMark pointer = BookMark(
        comicId,
        pageDisplayNumber,
        chapters.elementAt(indexList[pageDisplayNumber]).link,
        chapters.elementAt(indexList[pageDisplayNumber]).name);
    if (Provider.of<DatabaseProvider>(context, listen: false)
        .checkIfBookMarked(pointer))
      pageBookmarked = true;
    else
      pageBookmarked = false;
  }

  toggleShowControls() {
    showControls = !showControls;
    notifyListeners();
  }

  changeMode() {
    initialPageIndex = currentPage;
    print("Opening to $initialPageIndex");
    notifyListeners();
  }

  addChapterToView(ReaderChapter chapter) {
    /// Adds chapters to the pagelistview
    ReaderChapter current = readerChapters.last;
    Widget transition = TransitionPage(
      current: current,
      next: chapter,
    );
    widgetPageList.add(transition);
    for (ReaderPage page in chapter.pages) {
      Widget view = ImageHolder(
        page: page,
      );
      widgetPageList.add(view);
    }
    readerChapters.add(chapter);

    Map initialEntry = {chapter.index: chapter.pages.length};
    chapterHolder.addAll(initialEntry);
    notifyListeners();
  }

  loadNextChapter(int nextIndex) async {
    if (nextIndex < 0) {
      // no chapter after it.
      endReached();
    } else {
      Chapter chapter = chapters.elementAt(nextIndex);
      Chapter current = chapters.elementAt(currentIndex);

      if (chapter.generatedNumber == current.generatedNumber) {
        await loadNextChapter(nextIndex - 1);
      } else {
        // create chapter data object
        Provider.of<DatabaseProvider>(context, listen: false)
            .updateFromACS([chapter], comicId, false, source, selector);
        // Initialize Reader Chapter
        ReaderChapter readerChapter = ReaderChapter();
        readerChapter.chapterName = chapter.name;
        readerChapter.generatedNumber = chapter.generatedNumber;
        readerChapter.index = nextIndex;
        // Get Images
        ImageChapter response =
            await ApiManager().getImages(selector, chapter.link);
        try {
          await Provider.of<DatabaseProvider>(context, listen: false)
              .updateChapterImages(chapter, response.images);
          print("Images set for ${chapter.name}");
        } catch (err) {
          print("IMAGE ERROR: $err");
        }

        if (response.images.isEmpty) {
          emptyResponse();
        } else {
          int c = 0;
          pagePositionList.add(null); // for transition page
          indexList.add(null);

          for (String uri in response.images) {
            ReaderPage newPage = ReaderPage(c, uri, response.referer);
            readerChapter.pages.add(newPage);
            c++;
            pagePositionList.add(c);
            indexList.add(nextIndex);
          }
          print("appending to view");
          addChapterToView(readerChapter);
          print("done");
        }
      }
    }
  }

  bool pageBookmarked = false;

  pageChanged(int page) async {
    currentPage = page;
    currentIndex =
        indexList[page]; // get the current chapter index for the page
    pageDisplayNumber = pagePositionList[page];
    try {
      pageDisplayCount = readerChapters
          .firstWhere((element) => element.index == currentIndex)
          .pages
          .length;
    } catch (e) {
      pageDisplayCount = null;
    }
    try {
      currentChapterName = indexList[page] != null
          ? chapters.elementAt(indexList[page]).name
          : "";
      // check if page is bookmarked
      BookMark pointer = BookMark(
          comicId,
          pageDisplayNumber,
          chapters.elementAt(indexList[page]).link,
          chapters.elementAt(indexList[page]).name);
      if (Provider.of<DatabaseProvider>(context, listen: false)
          .checkIfBookMarked(pointer))
        pageBookmarked = true;
      else
        pageBookmarked = false;
      notifyListeners();
    } catch (e) {}

    /// History Update LOGIC
    try {
      if (!imgur) {
        Chapter pointer = chapters.elementAt(indexList[page]);
        Provider.of<DatabaseProvider>(context, listen: false)
            .updateHistoryFromChapter(comicId, pointer, pageDisplayNumber);
      }
    } catch (e) {
      // do nothing
    }

    /// UPDATE LOGIC
    if (pageDisplayCount != null &&
        pageDisplayNumber == pageDisplayCount &&
        page > lastPage &&
        !imgur) {
      // things to fix, going bac would cause next to be triggered
      int nextIndex = currentIndex - 1;
      print(chapterHolder.keys.toList());
      if (!chapterHolder.keys.contains(nextIndex)) {
        print("loading next");

        if (nextIndex < 0) {
          if (reachedEnd) {
            print("reached end, do nothing");
          } else
            endReached();
        } else {
          // Load Next chapter
          // Add to Read
          Provider.of<DatabaseProvider>(context, listen: false).updateFromACS(
              [chapters.elementAt(currentIndex)],
              comicId,
              true,
              source,
              selector);
          // MD Sync Logic
          if (selector == "mangadex") {
            SharedPreferences.getInstance().then((_prefs) async {
              if (_prefs.getString("mangadex_cookies") != null) {
                // Cookies containing profile exists
                // Sync to MD
                try {
                  ApiManager().syncChapters(
                      [chapters.elementAt(currentIndex).link], true);
                } catch (err) {
                  showSnackBarMessage(err);
                }
              }
            });
          }
          await loadNextChapter(nextIndex);
          currentIndex--;
        }
      }
    }

    lastPage = page;
  }

  toggleBookMark() async {
    pageBookmarked = !pageBookmarked;
    notifyListeners();
    BookMark pointer = BookMark(
        comicId,
        pageDisplayNumber,
        chapters.elementAt(indexList[currentPage]).link,
        chapters.elementAt(indexList[currentPage]).name);
    await Provider.of<DatabaseProvider>(context, listen: false)
        .toggleBookMark(pointer);
  }

  endReached() {
    reachedEnd = true;
    pagePositionList.add(null); // for transition page
    indexList.add(null);
    widgetPageList.add(
      ReachedEndPage(
        inLibrary: Provider.of<DatabaseProvider>(context, listen: false)
            .retrieveComic(comicId),
      ),
    );
  }

  emptyResponse() {
    reachedEnd = true;
    pagePositionList.add(null); // for transition page
    indexList.add(null);
    widgetPageList.add(
      EmptyResponsePage(),
    );
  }

  moveToChapter({bool next = true, int index}) async {
    if (index == null) {
      index = currentIndex;
    }
    // Might have to reinitialize entire reader
    int target;
    if (next) {
      // Move to Next chapter
      target = index - 1;
    } else {
      // Move to Previous Chapter
      target = index + 1;
    }

    if (target < 0) {
      // no chapter after it.
      showMessage(
          "Last chapter", Icons.skip_next_outlined, Duration(seconds: 1));
    } else if (target >= chapters.length) {
      // no chapters before it
      showMessage(
          "First Chapter", Icons.skip_previous_outlined, Duration(seconds: 1));
    } else {
      // Check for duplicates
      Chapter chapter = chapters.elementAt(target);
      Chapter current = chapters.elementAt(currentIndex);

      if (chapter.generatedNumber == current.generatedNumber) {
        // print("match at index: $target, ${chapter.generatedNumber} == ${current.generatedNumber}");
        await moveToChapter(next: next, index: target);
      } else {
        print("Changing Chapters");
        var c = List.of(chapters);
        var s = selector;
        var ctx = context;
        var id = comicId;
        var src = source;
        await init(c, target, s, ctx, id, src);
      }
    }
  }

  reset() {
    // Reset Variables

    readerChapters.clear();
    widgetPageList.clear();
    chapters.clear();
    selector = "";
    currentIndex = 0;
    currentChapter = null;
    pageDisplayNumber = 1;
    pageDisplayCount = 1;
    chapterHolder.clear();
    pagePositionList.clear();
    indexList.clear();
    currentChapterName = "";
    lastPage = 0;
    context = null;
    source = "";
    comicId = null;
    reachedEnd = false;
    imgur = false;
    initialPageIndex = 1;
    currentPage = 0;
    pageBookmarked = false;
  }
}
