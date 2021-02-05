import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/webtoon_reader/webtoon_view_holder.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reached_end_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reader_transition_page.dart';
import 'package:provider/provider.dart';

class ReaderProvider with ChangeNotifier {
  int comicId;
  String source;

  List<ReaderChapter> readerChapters = List(); // loaded chapters
  List<Widget> widgetPageList = List(); // Pages to be shown
  List<Chapter> chapters = List(); // the chapters from the profile
  List pagePositionList = List(); // the page number for each widget page
  List indexList = List(); // the chapter index for each page

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

  Future init(
      List<Chapter> incomingChapters,
      int initialIndex,
      String incomingSelector,
      BuildContext widgetContext,
      int comic_id,
      String incomingSource,
      {bool loaded = false,
        bool imgur = false,
      ImageChapter loadedChapter}) async {
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

    if (!imgur)
      await Provider.of<DatabaseProvider>(context, listen: false)
          .historyLogic(chapter, comicId, source, selector);

    // Initialize Reader Chapter
    ReaderChapter firstChapter = ReaderChapter();
    firstChapter.chapterName = chapter.name;
    firstChapter.generatedNumber = chapter.generatedNumber;
    firstChapter.index = initialIndex;

    // Get Images
    ImageChapter response = !loaded
        ? await ApiManager().getImages(selector, chapter.link)
        : loadedChapter;
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
    notifyListeners();
    return true;
  }

  addInitialChapterToView(ReaderChapter chapter) {
    /// This adds the initial ReaderChapter ReaderPages to the PageListView
    // Create Page Widgets, add to View

    for (ReaderPage page in chapter.pages) {
      Widget view = WebToonViewHolder(
        page: page,
      );
      widgetPageList.add(view);
    }
    readerChapters.add(chapter);

    Map initialEntry = {chapter.index: chapter.pages.length};
    chapterHolder.addAll(initialEntry);
    pageDisplayCount = chapter.pages.length;
    currentChapterName = chapter.chapterName;

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
    print(pagePositionList);
    for (ReaderPage page in chapter.pages) {
      Widget view = WebToonViewHolder(
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
    Chapter chapter = chapters.elementAt(nextIndex);

    // create chapteredata object
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

    addChapterToView(readerChapter);
  }

  pageChanged(int page) {
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

    currentChapterName =
    indexList[page] != null ? chapters
        .elementAt(indexList[page])
        .name : "";
    notifyListeners();

    /// History Update LOGIC
    try {
      Chapter pointer = chapters.elementAt(indexList[page]);
      Provider.of<DatabaseProvider>(context, listen: false)
          .updateChapterInfo(pageDisplayNumber, pointer);
      ChapterData pointed =
      Provider.of<DatabaseProvider>(context, listen: false)
          .checkIfChapterMatch(pointer);
      Provider.of<DatabaseProvider>(context, listen: false)
          .updateHistory(comicId, pointed.id);
    } catch (e) {
      // do nothing
    }

    /// UPDATE LOGIC
    if (pageDisplayCount != null &&
        pageDisplayNumber == pageDisplayCount &&
        page > lastPage) {
      // things to fix, going bac would cause next to be triggered
      int nextIndex = currentIndex - 1;
      print(chapterHolder.keys.toList());
      if (!chapterHolder.keys.contains(nextIndex)) {
        print("loading next");
        print(nextIndex);
        // Add to Read
        Provider.of<DatabaseProvider>(context, listen: false).updateFromACS(
            [chapters.elementAt(currentIndex)],
            comicId,
            true,
            source,
            selector);
        // Provider.of<DatabaseProvider>(context, listen: false).historyLogic(
        //     chapters.elementAt(currentIndex), comicId, source, selector);

        if (nextIndex < 0) {
          if (reachedEnd) {
            print("reached end, do nothing");
          } else
            endReached();
        } else {
          // Load Next chapter
          loadNextChapter(nextIndex);
          currentIndex--;
        }
      }
    }

    lastPage = page;
  }

  endReached() {
    reachedEnd = true;
    pagePositionList.add(null); // for transition page
    indexList.add(null);
    widgetPageList.add(ReachedEndPage());
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
  }
}
