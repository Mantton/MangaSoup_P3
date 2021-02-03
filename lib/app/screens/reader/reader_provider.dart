import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_holder.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reader_transition_page.dart';
import 'package:provider/provider.dart';

class ReaderProvider with ChangeNotifier {
  int comicId;
  String source;

  List<ReaderChapter> readerChapters = List();
  List<Widget> widgetPageList = List();
  List chapterLengthList = List();
  List<Chapter> chapters = List();
  String selector;
  int currentIndex = 0;
  ChapterData currentChapter;
  int pageDisplayNumber = 1;
  int pageDisplayCount = 1;
  Map chapterHolder = Map();
  List pagePositionList = List();
  List chapterNameList = List();
  String currentChapterName = "";
  int lastPage;
  BuildContext context;

  Future init(
      List<Chapter> incomingChapters,
      int initialIndex,
      String incomingSelector,
      BuildContext widgetContext,
      int comic_id,
      String incomingSource) async {
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

    // Initialize Reader Chapter
    ReaderChapter firstChapter = ReaderChapter();
    firstChapter.chapterName = chapter.name;
    firstChapter.generatedNumber = chapter.generatedNumber;
    firstChapter.index = 0;

    // Get Images
    ImageChapter response =
    await ApiManager().getImages(selector, chapter.link);
    int c = 0;
    for (String uri in response.images) {
      ReaderPage newPage = ReaderPage(c + 1, uri, response.referer);
      firstChapter.pages.add(newPage);
      c++;
      pagePositionList.add(c);
      chapterLengthList.add(response.images.length);
      chapterNameList.add(firstChapter.chapterName);
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
      Widget view = PagedViewHolder(
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
      Widget view = PagedViewHolder(
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
    chapterLengthList.add(null);
    chapterNameList.add(null);

    for (String uri in response.images) {
      ReaderPage newPage = ReaderPage(c, uri, response.referer);
      readerChapter.pages.add(newPage);
      c++;
      pagePositionList.add(c);
      chapterLengthList.add(response.images.length);
      chapterNameList.add(readerChapter.chapterName);
    }

    addChapterToView(readerChapter);

    /// todo,
    /// mark as read
    /// update read history
    /// settings rework then comeback to reader
  }

  pageChanged(int page) {
    pageDisplayNumber = pagePositionList[page];
    pageDisplayCount = chapterLengthList[page];
    currentChapterName = chapterNameList[page];

    notifyListeners();

    // Check location of page
    if (pageDisplayCount != null && pageDisplayNumber == pageDisplayCount &&
        page > lastPage) {
      // things to fix, going bac would cause next to be triggered
      int nextIndex = currentIndex - 1;
      if (!chapterHolder.keys.contains(nextIndex)) {
        print("loading next");
        print(nextIndex);
        // Add to Read
        Provider.of<DatabaseProvider>(context, listen: false).updateFromACS(
            [chapters.elementAt(currentIndex)], comicId, true, source,
            selector);

        // Load Next chapter
        loadNextChapter(nextIndex);
        currentIndex--;
      }
    }

    lastPage = page;
  }

  reset() {
    // Reset Variables

    readerChapters.clear();
    widgetPageList.clear();
    chapterLengthList.clear();
    chapters.clear();
    selector = "";
    currentIndex = 0;
    currentChapter = null;
    pageDisplayNumber = 1;
    pageDisplayCount = 1;
    chapterHolder.clear();
    pagePositionList.clear();
    chapterNameList.clear();
    currentChapterName = "";
    lastPage = 0;
    context = null;
    source = "";
    comicId = null;
  }
}
