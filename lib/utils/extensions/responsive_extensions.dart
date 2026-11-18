import 'package:sizer/sizer.dart';

/// every dimension in the app goes through these. raw pixel literals are
/// banned, so this is the only place the scaling rule lives.
///
/// the design frames are 390pt wide (iphone 14 class), so [rw] scales a design
/// width against that reference and [rh] scales a design height against 844pt.
extension ResponsiveNum on num {
  /// design width → responsive width
  double get rw => (this / 390) * 100.w;

  /// design height → responsive height
  double get rh => (this / 844) * 100.h;

  /// font size. deliberately tied to width so text does not reflow between
  /// portrait and landscape.
  double get rf => (this / 390) * 100.w;

  /// square side / icon size / radius
  double get r => (this / 390) * 100.w;
}
