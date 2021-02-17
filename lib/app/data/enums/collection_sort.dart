import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';

enum Sort {
  date_added,
  name,
  update_count,
  // unread_count,
  chapter_count,
  rating,
}

List collectionSortNames = [
  "Date Added",
  "Name",
  "Update Count",
  // "Unread Chapter Count",
  "Chapter Count",
  "Rating"
];

List<Comic> sortComicCollection(int sort, List<Comic> comics) {
  if (sort == Sort.date_added.index)
    comics.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  else if (sort == Sort.name.index)
    comics.sort((a, b) => a.title.compareTo(b.title));
  else if (sort == Sort.update_count.index)
    comics.sort((a, b) => b.updateCount.compareTo(a.updateCount));
  else if (sort == Sort.chapter_count.index)
    comics.sort((a, b) => b.chapterCount.compareTo(a.chapterCount));
  else if (sort == Sort.rating.index)
    comics.sort((a, b) => b.rating.compareTo(a.rating));
  return comics;
}
