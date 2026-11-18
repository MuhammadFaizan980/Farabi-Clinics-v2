import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:farabi_booking_app/app_di.dart';
import 'package:farabi_booking_app/data/auth_session.dart';
import 'package:farabi_booking_app/data/constants/app_locales.dart';
import 'package:farabi_booking_app/data/constants/codegen_loader.g.dart';
import 'package:farabi_booking_app/data/network/end_points.dart';
import 'package:farabi_booking_app/main_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// phase 9: proves the app runs right-to-left in arabic with real data, and
/// that touch targets stay above the 44pt minimum.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFor(WidgetTester tester, Duration total) async {
    final end = DateTime.now().add(total);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> bootArabic(WidgetTester tester) async {
    await AppDi.reset();
    await EasyLocalization.ensureInitialized();
    await AppDi.initDi(baseUrl: EndPoints.baseUrlDev, enableLogging: false);
    await AppDi.locator<AuthSession>().setLanguageCode('ar');

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: AppLocales.supported,
        path: AppLocales.path,
        fallbackLocale: AppLocales.english,
        startLocale: AppLocales.arabic,
        assetLoader: const CodegenLoader(),
        child: const FarabiBookingApp(),
      ),
    );
    await pumpFor(tester, const Duration(seconds: 8));
  }

  testWidgets('arabic boots right-to-left', (tester) async {
    await bootArabic(tester);

    // MaterialApp installs Directionality *below* itself, so the check has to
    // come from inside a screen, not from the app element
    final screen = tester.element(find.byType(Scaffold).first);
    // easy_localization re-exports intl, which also defines TextDirection
    expect(Directionality.of(screen), ui.TextDirection.rtl);
    expect(
      tester.element(find.byType(MaterialApp)).locale.languageCode,
      'ar',
    );
  });

  testWidgets('arabic shell shows translated tabs, not english fallbacks',
      (tester) async {
    await bootArabic(tester);

    if (find.text('متابعة').evaluate().isNotEmpty) {
      await tester.tap(find.text('متابعة'));
      await pumpFor(tester, const Duration(seconds: 8));
    }

    // arabic tab labels, and no english leaking through
    expect(find.text('الرئيسية'), findsWidgets);
    expect(find.text('الأطباء'), findsWidgets);
    expect(find.text('الفروع'), findsWidgets);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Doctors'), findsNothing);
  });

  testWidgets('arabic doctors tab renders real api data in arabic',
      (tester) async {
    await bootArabic(tester);
    if (find.text('متابعة').evaluate().isNotEmpty) {
      await tester.tap(find.text('متابعة'));
      await pumpFor(tester, const Duration(seconds: 8));
    }

    await tester.tap(find.text('الأطباء').last);
    await pumpFor(tester, const Duration(seconds: 10));

    // the api localises `name` off the lang header
    expect(find.textContaining('د.'), findsWidgets);
  });

  testWidgets('every tappable target clears the 44pt minimum', (tester) async {
    await bootArabic(tester);
    if (find.text('متابعة').evaluate().isNotEmpty) {
      await tester.tap(find.text('متابعة'));
      await pumpFor(tester, const Duration(seconds: 8));
    }

    final tooSmall = <String>[];
    for (final element in find.byType(InkWell).evaluate()) {
      final size = element.size;
      if (size == null || size.isEmpty) continue;
      // ignore zero-height wrappers that are not really targets
      if (size.height < 44 && size.height > 1) {
        tooSmall.add('InkWell ${size.width.toStringAsFixed(0)}x'
            '${size.height.toStringAsFixed(0)}');
      }
    }
    expect(tooSmall, isEmpty, reason: tooSmall.join(', '));
  });
}
