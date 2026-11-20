import 'package:flutter/foundation.dart';

/// lets another screen (the Home region cards) ask the Branches tab to open on
/// a given region, like the site's `/branches?region=` link. the tab consumes
/// the value and resets it.
class BranchesRegionRequest {
  BranchesRegionRequest._();

  static final ValueNotifier<int?> regionId = ValueNotifier<int?>(null);
}
