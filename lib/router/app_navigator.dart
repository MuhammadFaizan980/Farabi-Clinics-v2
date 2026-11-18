import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

GlobalKey<NavigatorState> getAppNavigator() => _navigatorKey;

/// navigation helper. repos never touch this; view models do.
class AppNavigator {
  AppNavigator._();

  static NavigatorState? get _state => _navigatorKey.currentState;

  static Future<T?> push<T>(String route, {Object? arguments}) async =>
      _state?.pushNamed<T>(route, arguments: arguments);

  static Future<T?> replaceWith<T>(String route, {Object? arguments}) async =>
      _state?.pushReplacementNamed<T, void>(route, arguments: arguments);

  static Future<T?> resetTo<T>(String route, {Object? arguments}) async =>
      _state?.pushNamedAndRemoveUntil<T>(
        route,
        (_) => false,
        arguments: arguments,
      );

  static void pop<T>([T? result]) => _state?.pop(result);

  static bool get canPop => _state?.canPop() ?? false;
}
