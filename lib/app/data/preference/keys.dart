class PreferenceKeys {

  /// READER KEYS
  static const READER_MODE = "reader_mode"; // Manga or Webtoon
  static const READER_SCROLL_DIRECTION =
      "reader_scroll_direction"; // LTR or TRL

  static const MANGA_ORIENTATION =
      "manga_mode_orientation"; // Vertical or Horizontal
  static const MANGA_PADDING = "manga_mode_padding"; // True or False
  static const MANGA_SNAPPING = "manga_mode_snapping"; // True or False

  static const WEBTOON_MSV =
      "webtoon_max_scroll_velocity"; // 2500, 3000, 4000, 5000, 6000, 7000, 8000, 8500

  /// MANGADEX KEYS
  static const MANGADEX_PROFILE = "mangadex_profile"; // Json Object

  /// GENERAL KEYS
  static const COMIC_GRID_CROSS_AXIS_COUNT = "cgcac";
  static const SCALE_GRID_TO_MATCH_INTENDED = "stmi";
  static const LIBRARY_VIEW_TYPE = "library_view_type";
  static const LIBRARY_SHOW_UNREAD_COUNT = "library_show_unread_count";
}
