import 'package:flutter/material.dart';

import '../../utils/extensions/responsive_extensions.dart';

class AppBorderRadius {
  AppBorderRadius._();

  static BorderRadius get xs => BorderRadius.circular(6.r);
  static BorderRadius get sm => BorderRadius.circular(10.r);
  static BorderRadius get md => BorderRadius.circular(12.r);
  static BorderRadius get lg => BorderRadius.circular(16.r);
  static BorderRadius get xl => BorderRadius.circular(24.r);
  static BorderRadius get pill => BorderRadius.circular(999.r);
}
