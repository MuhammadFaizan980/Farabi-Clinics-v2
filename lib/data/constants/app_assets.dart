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

  // booking and checkout
  static const String iconSar = '$_svg/icons/sar.svg';
  static const String iconEditPencil = '$_svg/icons/edit_pencil.svg';
  static const String iconBranchTile = '$_svg/icons/branch_tile.svg';
  static const String iconClockTile = '$_svg/icons/clock_tile.svg';
  static const String iconCalendarSmall = '$_svg/icons/calendar_small.svg';
  static const String iconClockSmall = '$_svg/icons/clock_small.svg';
  static const String iconBookingFeeArrow = '$_svg/icons/booking_fee_arrow.svg';
  static const String iconChevronRightThick =
      '$_svg/icons/chevron_right_thick.svg';

  static const String iconStatPatients = '$_svg/icons/stat_patients.svg';
  static const String iconStatExperience = '$_svg/icons/stat_experience.svg';
  static const String iconStatSatisfaction =
      '$_svg/icons/stat_satisfaction.svg';

  static const String iconUserPinRed = '$_svg/icons/user_pin_red.svg';
  static const String iconUserPinDark = '$_svg/icons/user_pin_dark.svg';

  // more
  static const String _more = '$_svg/icons/more';
  static const String moreVerified = '$_more/verified_badge.svg';
  static const String morePatientId = '$_more/patient_id.svg';
  static const String moreStatUpcoming = '$_more/stat_upcoming.svg';
  static const String moreStatBooked = '$_more/stat_booked.svg';
  static const String moreStatVisits = '$_more/stat_visits.svg';
  static const String moreRowAppointments = '$_more/row_appointments.svg';
  static const String moreRowLanguage = '$_more/row_language.svg';
  static const String moreRowAbout = '$_more/row_about.svg';
  static const String moreChevron = '$_more/chevron_right.svg';
  static const String moreLogout = '$_more/logout.svg';

  // branches
  static const String iconMapSearch = '$_svg/icons/map_search.svg';
  static const String iconPinOutlineWhite = '$_svg/icons/pin_outline_white.svg';
  static const String iconCall = '$_svg/icons/call.svg';
  static const String iconClosesAt = '$_svg/icons/closes_at.svg';
  static const String iconDistance = '$_svg/icons/distance.svg';

  // home
  static const String iconChevronDown = '$_svg/icons/chevron_down_vector.svg';
  static const String iconLocationPin = '$_svg/icons/location_pin.svg';
  static const String iconVirtualVideo = '$_svg/icons/virtual_video.svg';
  static const String iconVirtualAudio = '$_svg/icons/virtual_audio.svg';
  static const String iconVirtualArrow = '$_svg/icons/virtual_arrow.svg';
  static const String iconAiButton = '$_svg/icons/ai_button.svg';
  static const String imageBookingSuccess = '$_img/booking_success.png';
  static const String imageExpertConsult = '$_img/expert_consult.png';

  /// city photos keyed by the regions api's `name_en`. the api has no image
  /// field. Riyadh and Medina come from the Figma home frame; Jeddah, Mecca and
  /// Dammam are free-licence Wikimedia Commons photos (credits in
  /// docs/image-credits.md) because the design has none for them.
  static const Map<String, String> _regionImages = {
    'riyadh': '$_img/regions/riyadh.png',
    'medina': '$_img/regions/medina.png',
    'jeddah': '$_img/regions/jeddah.jpg',
    'mecca': '$_img/regions/mecca.jpg',
    'dammam': '$_img/regions/dammam.jpg',
  };

  static String? regionImage(String? nameEn) =>
      _regionImages[(nameEn ?? '').trim().toLowerCase()];
  static const String logoCbahi = '$_svg/brand/cbahi.svg';

  // bottom navigation: each tab has a two-tone Figma icon per state (the
  // selected one carries the red accent, the unselected one the grey accent)
  static const String navHomeOff = '$_svg/nav/nav_home_off.svg';
  static const String navHomeOn = '$_svg/nav/nav_home_on.svg';
  static const String navDoctorsOff = '$_svg/nav/nav_doctors_off.svg';
  static const String navDoctorsOn = '$_svg/nav/nav_doctors_on.svg';
  static const String navOffersOff = '$_svg/nav/nav_offers_off.svg';
  static const String navOffersOn = '$_svg/nav/nav_offers_on.svg';
  static const String navBranchesOff = '$_svg/nav/nav_branches_off.svg';
  static const String navBranchesOn = '$_svg/nav/nav_branches_on.svg';
  static const String navMoreOff = '$_svg/nav/nav_more_off.svg';
  static const String navMoreOn = '$_svg/nav/nav_more_on.svg';
}
