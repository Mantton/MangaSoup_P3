import 'package:mangasoup_prototype_3/app/data/database/models/chapter.dart';

class ChapterRecognition {
  // Used tachiyomi as inspiration
  /// All cases with Ch.xx
  /// Mokushiroku Alice Vol.1 Ch. 4: Misrepresentation -R> 4
  final basic = RegExp(r"""(?<=ch\.) *([0-9]+)(\.[0-9]+)?(\.?[a-z]+)?""");

  /// Regex used when only one number occurrence
  /// Example: Bleach 567: Down With Snowwhite -R> 567
  final occurrence = RegExp(r"""([0-9]+)(\.[0-9]+)?(\.?[a-z]+)?""");

  /// Regex used when manga title removed
  /// Example: Solanin 028 Vol. 2 -> 028 Vol.2 -> 028Vol.2 -R> 028
  final withoutManga = RegExp(r"""^([0-9]+)(\.[0-9]+)?(\.?[a-z]+)?""");

  /// Regex used to remove unwanted tags
  /// Example Prison School 12 v.1 vol004 version1243 volume64 -R> Prison School 12
  final unwanted =
      RegExp(r"""(?<![a-z])(v|ver|vol|version|volume|season|s).?[0-9]+""");

  /// Regex used to remove unwanted whitespace
  /// Example One Piece 12 special -R> One Piece 12special
  final unwantedWhiteSpace = RegExp(r"""(\s)(extra|special|omake)""");

  double parseChapterNumber(String chapter, String comicName) {
    // Prepare title
    chapter = chapter.toLowerCase();
    chapter = chapter.replaceAll(",", ".");
    // Unwanted White Space
    chapter = chapter.replaceAllMapped(unwantedWhiteSpace, (match) {
      return match.group(0).trim();
    });

    // Unwanted
    chapter = chapter.replaceAllMapped(unwanted, (match) {
      return "";
    });

    RegExpMatch basicMatch = basic.firstMatch(chapter);
    if (check(basicMatch)) {
      return update(basicMatch);
    }
    List<RegExpMatch> test = List();
    occurrence.allMatches(chapter).forEach((element) => test.add(element));

    if (test.length == 1) {
      if (check(test[0])) return update(test[0]);
    }

    String nameWithoutManga =
        chapter.replaceAll(comicName.toLowerCase(), "").trim();

    RegExpMatch nwm = withoutManga.firstMatch(nameWithoutManga);
    if (check(nwm)) return update(nwm);

    RegExpMatch firstOccurrence = occurrence.firstMatch(nameWithoutManga);
    if (check(firstOccurrence)) return update(firstOccurrence);
    return 0.0;
  }

  bool check(RegExpMatch match) {
    if (match != null) {
      return true;
    }
    return false;
  }

  double update(RegExpMatch match) {
    var initial = match.group(1) ?? "";
    var subChapterDecimal = match.group(2) ?? "";
    var subChapterAlpha = match.group(3) ?? "";
    var addition = checkForDecimal(subChapterDecimal, subChapterAlpha);
    var x = double.parse(initial) + (addition);
    return x;
  }

  double checkForDecimal(String decimal, String alpha) {
    if (decimal.isNotEmpty) {
      return double.parse(decimal);
    }

    if (alpha.isNotEmpty) {
      if (alpha.contains("extra")) {
        return .98;
      }

      if (alpha.contains("omake")) {
        return .98;
      }

      if (alpha.contains("special")) {
        return .97;
      }

      if (alpha[0] == '.') {
        // Take value after (.)
        return parseAlphaPostFix(alpha[1]);
      } else {
        return parseAlphaPostFix(alpha[0]);
      }
    }

    return .00;
  }

  parseAlphaPostFix(String alpha) {
    return double.parse("0." + (int.parse(alpha) - 96).toString());
  }
}
