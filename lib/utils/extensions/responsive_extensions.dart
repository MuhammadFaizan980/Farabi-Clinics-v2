import 'package:sizer/sizer.dart';

/// every dimension in the app goes through these. raw pixel literals are
/// banned, so this is the only place the scaling rule lives.
///
/// the figma frames are 414pt wide (measured from the frame properties), so
/// [rw] scales a design width against that reference and [rh] scales a design
/// height against the 896pt device height of that frame class.
extension ResponsiveNum on num {
  /// design width → responsive width
  double get rw => (this / 414) * 100.w;

  /// design height → responsive height
  double get rh => (this / 896) * 100.h;

  /// font size. deliberately tied to width so text does not reflow between
  /// portrait and landscape.
  double get rf => (this / 414) * 100.w;

  /// square side / icon size / radius
  double get r => (this / 414) * 100.w;
}
