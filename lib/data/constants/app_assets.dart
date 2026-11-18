class AppAssets {
  AppAssets._();

  static const String _svg = 'assets/svgs';
  static const String _img = 'assets/images';

  // header
  static const String logoWordmarkWhite = '$_svg/icons/logo_wordmark_white.svg';
  static const String iconBell = '$_svg/icons/bell.svg';
  static const String iconUser = '$_svg/icons/user.svg';
  static const String iconSearch = '$_svg/icons/search.svg';

  // doctors
  static const String iconFilter = '$_svg/icons/filter.svg';
  static const String iconGridView = '$_svg/icons/grid_view.svg';

  // home
  static const String iconChevronDown = '$_svg/icons/chevron_down_vector.svg';
  static const String iconLocationPin = '$_svg/icons/location_pin.svg';
  static const String iconVirtualVideo = '$_svg/icons/virtual_video.svg';
  static const String iconVirtualAudio = '$_svg/icons/virtual_audio.svg';
  static const String iconVirtualArrow = '$_svg/icons/virtual_arrow.svg';
  static const String iconAiButton = '$_svg/icons/ai_button.svg';
  static const String imageExpertConsult = '$_img/expert_consult.png';

  /// city photos from the home frame, keyed by the regions api's `name_en`.
  /// the api has no image field; Dammam's frame photo is clipped by the
  /// artboard edge, and Jeddah and Mecca have none in the design.
  static const Map<String, String> _regionImages = {
    'riyadh': '$_img/regions/riyadh.png',
    'medina': '$_img/regions/medina.png',
  };

  static String? regionImage(String? nameEn) =>
      _regionImages[(nameEn ?? '').trim().toLowerCase()];
  static const String logoCbahi = '$_svg/brand/cbahi.svg';

  // bottom navigation
  static const String navHome = '$_svg/nav/nav_home.svg';
  static const String navDoctors = '$_svg/nav/nav_doctors.svg';
  static const String navOffers = '$_svg/nav/nav_offers.svg';
  static const String navBranches = '$_svg/nav/nav_branches.svg';
  static const String navMore = '$_svg/nav/nav_more.svg';
}
