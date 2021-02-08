// import 'package:flutter/cupertino.dart';
// import 'package:mangasoup_prototype_3/Components/Messages.dart';
// import 'package:mangasoup_prototype_3/Models/ImageChapter.dart';
// import 'package:mangasoup_prototype_3/Models/Misc.dart';
// import 'package:mangasoup_prototype_3/Services/api_manager.dart';
// import 'package:provider/provider.dart';
//
// class ReaderProvider with ChangeNotifier {
//   ApiManager _apiManager = ApiManager();
//
//   ///
//   bool downloaded;
//   bool custom;
//   bool loadingMore = false;
//   String source;
//   int chapterLength;
//
//   bool lastChapter;
//   bool firstChapter;
//   bool onlyChapter;
//   bool edgeReached = false;
//
//   /// Chapter
//   Chapter currentChapter;
//   Chapter previousChapter;
//   Chapter nextChapter;
//   Chapter lastLoaded;
//   List<Chapter> chapterList;
//   int chapterIndex;
//
//   /// Images
//   List<ImageChapter> loadedChapters = List();
//   ImageChapter currentImageChapter;
//   ImageChapter previousImageChapter;
//   ImageChapter nextImageChapter;
//
//   init({
//     @required ImageChapter imageChapter,
//     @required Chapter selectedChapter,
//     @required bool isDownloaded,
//     @required bool isCustom,
//     @required List<Chapter> chapterListObject,
//     @required String chapterSource,
//   }) {
//     clear();
//     loadedChapters.add(imageChapter);
//
//     // Testing new
//     currentChapter = selectedChapter;
//     downloaded = isDownloaded;
//     custom = isCustom;
//     currentImageChapter = imageChapter;
//     print(imageChapter.link);
//     chapterList = chapterListObject;
//     page = 1;
//     edgeReached = false;
//
//     source = chapterSource;
//     lastLoaded = currentChapter;
//     chapterLength = currentImageChapter.count;
//     if (chapterList != null) {
//       chapterIndex = chapterList
//           .indexWhere((element) => element.link == currentChapter.link);
//       print(chapterIndex);
//     }
//
//     notifyListeners();
//   }
//
//   setImageChapter(int chapter) {
//     currentImageChapter = loadedChapters[chapter];
//     chapterLength = currentImageChapter.count;
//     if (chapterList.isNotEmpty) {
//       currentChapter = chapterList
//           .firstWhere((element) => element.link == currentImageChapter.link);
//     }
//     notifyListeners();
//   }
//
//   clear() {
//     currentChapter =
//         previousChapter = nextChapter = chapterList = chapterIndex = null;
//     currentImageChapter = previousImageChapter = nextImageChapter = null;
//     loadedChapters.clear();
//   }
//
//   Future<ImageChapter> loadChapter(Chapter chapter, String source) async {
//     return await _apiManager.getImages(source, chapter.link);
//   }
//
//   addChapter({BuildContext context}) async {
//     if (currentImageChapter == loadedChapters.last) {
//       loadingMore = true;
//
//       int newIndex = chapterIndex - 1;
//       // int newIndex = currentIndex - 1;
//
//       if (newIndex < 0) {
//         if (!edgeReached) {
//           // If Message has not been shown, show message
//           /// Add to Read
//           try {
//             Chapter oldChapter = chapterList[chapterIndex];
//
//           } catch (err) {
//             showSnackBarMessage("Unable to mark as read");
//           }
//
//           /// Display Reached Edge Notifier
//           edgeReached = true;
//           debugPrint("Edge Reached");
//           showSnackBarMessage("This is the last available chapter");
//         }
//       } else {
//         Chapter oldChapter = chapterList[chapterIndex];
//         Chapter newChapter = chapterList[newIndex];
//
//         try {
//           /// Add to Read
//           try {
//
//           } catch (err) {
//             showSnackBarMessage("Unable to mark as read");
//           }
//
//           if (oldChapter.name == newChapter.name) {
//             debugPrint("Duplicate");
//           }
//
//           debugPrint("Loading Next \n"
//               "Chapter Index: $chapterIndex");
//
//           ImageChapter c = await loadChapter(newChapter, source);
//           showSnackBarMessage("Next Chapter Loaded!");
//           loadedChapters.add(c);
//           chapterIndex = newIndex;
//           edgeReached = false;
//           print("Append Complete");
//         } catch (err) {
//           showSnackBarMessage("Next Chapter Load Failed.");
//           debugPrint(err);
//         }
//       }
//       loadingMore = false;
//       notifyListeners();
//     }
//   }
//
//   /// Reader Mode
//   int readerMode = 0;
//   Map readerModeOptions = {
//     0: "Manga",
//     1: "Webtoon",
//   };
//
//   setReaderMode(int mode) {
//     readerMode = mode;
//     notifyListeners();
//   }
//
//   /// Orientation
//   int orientationMode = 0;
//   Map orientationOptions = {
//     0: "Horizontal",
//     1: "Vertical",
//   };
//
//   setOrientationMode(int mode) {
//     orientationMode = mode;
//     notifyListeners();
//   }
//
//   /// Scroll Direction
//   int scrollDirectionMode = 0;
//   Map scrollDirectionOptionsHorizontal = {
//     0: "Left to Right",
//     1: "Right to Left",
//   };
//   Map scrollDirectionOptionsVertical = {
//     0: "Vertical Drag Down",
//     1: "Vertical Drag Up",
//   };
//
//   setScrollDirectionMode(int mode) {
//     scrollDirectionMode = mode;
//     notifyListeners();
//   }
//
//   /// Snapping
//   int snappingMode = 0;
//   Map snappingModeOptions = {
//     0: true,
//     1: false,
//   };
//
//   setSnappingMode(int mode) {
//     snappingMode = mode;
//     notifyListeners();
//   }
//
//   /// Padding
//   int paddingMode = 0;
//   Map paddingModeOptions = {
//     0: true,
//     1: false,
//   };
//
//   setPaddingMode(int mode) {
//     paddingMode = mode;
//     notifyListeners();
//   }
//
//   /// Page
//   int page = 1;
//
//   setPage(int p, bool vertical) {
//     if (vertical)
//       page = p;
//     else
//       page = p + 1;
//     notifyListeners();
//   }
// }
