
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_holder.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reader_transition_page.dart';

class ReaderProvider with ChangeNotifier{

  List<ReaderPage> pages = List();
  List<Widget> widgetPageList = List();

  List<Chapter> chapters = List();
  String selector;
  int currentIndex = 0;
  ChapterData currentChapter;
  int pageDisplayNumber = 1;

  Future init(List<Chapter> incomingChapters, int initialIndex, String incomingSelector) async{
    reset();
    // Create Starting values
    chapters = List.of(incomingChapters);
    currentIndex = initialIndex;
    selector = incomingSelector;

    Chapter chapter = incomingChapters.elementAt(initialIndex);
    print("${chapter.link}");
    ImageChapter response =
        await ApiManager().getImages(selector, chapter.link);
    int c = 0;
    for (String uri in response.images){
      ReaderPage newPage = ReaderPage(c, uri, response.referer);
      Widget widgetPage = PagedViewHolder(
        page: newPage,
      );
      widgetPageList.add(widgetPage);
      c++;
    }

    notifyListeners();
    return true;
  }

  reset(){
    // Reset Variables
    pages.clear();
    widgetPageList.clear();
    chapters.clear();
    selector = '';
    currentIndex = 0;
    currentChapter= null;
    pageDisplayNumber = 1;
  }
  pageChangeLogic(int index){
    /// What to do when the page is changed in the PageView
    currentIndex = index; // Update Current Index
    ReaderPage currentPage = pages[index];

    if (currentPage.index == currentChapter.images.length){
      /// LAST PAGE, APPEND NEXT CHAPTER

    }

    pageDisplayNumber = currentPage.index;
    notifyListeners();
  }


  appendChapter(Chapter chapter){
    // Load Chapter
    // Create ChapterData

  }

  transition(Chapter current, Chapter next){
    widgetPageList.add(TransitionPage(current: current,next: next,));
  }
}