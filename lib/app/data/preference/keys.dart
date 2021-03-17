class PreferenceKeys {
  /// SERVER
  static const MS_LANG_SERVER = "ms_lang_server";

  /// READER KEYS
  static const READER_MODE = "reader_mode"; // Manga or Webtoon
  static const READER_SCROLL_DIRECTION =
      "reader_scroll_direction"; // LTR or TRL

  static const MANGA_ORIENTATION =
      "manga_mode_orientation"; // Vertical or Horizontal
  static const MANGA_PADDING = "manga_mode_padding"; // True or False
  static const MANGA_SNAPPING = "manga_mode_snapping"; // True or False
  static const READER_MAX_WIDTH = "max_reader_width"; // override reader width
  static const READER_DOUBLE_MODE = "reader_double_paged"; // double page mode

  static const WEBTOON_MSV =
      "webtoon_max_scroll_velocity"; // 2500, 3000, 4000, 5000, 6000, 7000, 8000, 8500

  /// MANGADEX KEYS
  static const MANGADEX_PROFILE = "mangadex_profile"; // Json Object

  /// GENERAL KEYS
  static const COMIC_GRID_CROSS_AXIS_COUNT = "cgcac";
  static const SCALE_GRID_TO_MATCH_INTENDED = "stmi";
  static const LIBRARY_VIEW_TYPE = "library_view_type";
  static const LIBRARY_SHOW_UNREAD_COUNT = "library_show_unread_count";
  static const MAL_AUTH = "mal_auth_body";
  static const MAL_AUTO_SYNC = "mal_auto_sync";
  static const READER_BG_COLOR = "reader_bg_color";
  static const COMIC_GRID_MODE = 'comic_grid_mode';

  /// MANGASOUP KEYS
  static const MS_T_ACCESS_TOKEN = "ms_token_t";
  static const MS_T_USER = "ms_user_t";
  static const UPDATE_ON_STARTUP = "uonsp";
  static const SHOW_UNREAD_COUNT = "show_unread";
}
