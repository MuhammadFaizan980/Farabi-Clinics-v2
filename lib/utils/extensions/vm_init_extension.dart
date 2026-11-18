import 'package:flutter/widgets.dart';

/// runs a view model's first load *after* the first frame. calling it inline
/// from onViewModelReady notifies listeners while the tree is still building,
/// which the live test binding (rightly) rejects.
void runAfterFirstFrame(VoidCallback action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}
