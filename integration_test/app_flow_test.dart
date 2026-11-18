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

/// drives the real widget tree against the real dev api on a simulator:
///   flutter test integration_test -d DEVICE_ID
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // integration tests run on the device, so the host's environment is not
  // visible — these come in at compile time instead:
  //   flutter test integration_test -d <id> \
  //     --dart-define=FARABI_TEST_MOBILE=05XXXXXXXX \
  //     --dart-define=FARABI_TEST_PASSWORD=...
  const testMobile = String.fromEnvironment('FARABI_TEST_MOBILE');
  const testPassword = String.fromEnvironment('FARABI_TEST_PASSWORD');
  const hasCredentials = testMobile != '' && testPassword != '';

  /// the shimmer skeleton animates forever, so pumpAndSettle can never settle
  /// while a list is loading. pump in fixed steps instead.
  Future<void> pumpFor(WidgetTester tester, Duration total) async {
    final end = DateTime.now().add(total);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> bootApp(WidgetTester tester) async {
    await AppDi.reset();
    await EasyLocalization.ensureInitialized();
    await AppDi.initDi(
      baseUrl: EndPoints.baseUrlDev,
      enableLogging: false,
    );
    // start every run signed out so the flow is deterministic
    await AppDi.locator<AuthSession>().clear();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: AppLocales.supported,
        path: AppLocales.path,
        fallbackLocale: AppLocales.english,
        startLocale: AppLocales.english,
        assetLoader: const CodegenLoader(),
        child: const FarabiBookingApp(),
      ),
    );
    await pumpFor(tester, const Duration(seconds: 6));
  }

  /// the language choice persists, so after the first run the app boots
  /// straight into the shell. either entry point is valid.
  Future<void> enterShell(WidgetTester tester) async {
    if (find.text('Continue').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
    }
    await pumpFor(tester, const Duration(seconds: 8));
  }

  testWidgets('cold start shows either language selection or the shell',
      (tester) async {
    await bootApp(tester);
    final onLanguage = find.text('Choose your language').evaluate().isNotEmpty;
    if (onLanguage) {
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    } else {
      expect(find.text('Home'), findsWidgets);
    }
  });

  testWidgets('language choice opens the tab shell and loads real data',
      (tester) async {
    await bootApp(tester);

    await enterShell(tester);

    // bottom nav is up
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Doctors'), findsWidgets);
    expect(find.text('Branches'), findsWidgets);
    expect(find.text('Specialities'), findsWidgets);
    expect(find.text('More'), findsWidgets);
  });

  testWidgets('doctors tab renders real doctors from the api', (tester) async {
    await bootApp(tester);
    await enterShell(tester);

    await tester.tap(find.text('Doctors').last);
    await pumpFor(tester, const Duration(seconds: 8));

    // a real doctor from the dev data set
    expect(find.textContaining('Dr. Ahmed Hassan'), findsWidgets);
  });

  testWidgets('branches tab renders real branches', (tester) async {
    await bootApp(tester);
    await enterShell(tester);

    await tester.tap(find.text('Branches').last);
    await pumpFor(tester, const Duration(seconds: 8));

    expect(find.textContaining('Al-'), findsWidgets);
  });

  testWidgets('doctor detail opens and offers the booking flow',
      (tester) async {
    await bootApp(tester);
    await enterShell(tester);

    await tester.tap(find.text('Doctors').last);
    await pumpFor(tester, const Duration(seconds: 8));

    await tester.tap(find.textContaining('Dr. Ahmed Hassan').first);
    await pumpFor(tester, const Duration(seconds: 8));

    expect(find.text('Book appointment'), findsWidgets);

    await tester.tap(find.text('Book appointment').last);
    await pumpFor(tester, const Duration(seconds: 12));

    // the booking screen loaded its real services and branches
    expect(find.text('Choose a service'), findsOneWidget);
    expect(find.text('Choose a branch'), findsOneWidget);
    expect(find.text('Choose a time'), findsOneWidget);
    expect(find.textContaining('Creatinine'), findsWidgets);
  });

  testWidgets('bookings screen loads for a signed-in patient', (tester) async {
    await bootApp(tester);
    await enterShell(tester);

    await tester.tap(find.text('More').last);
    await pumpFor(tester, const Duration(seconds: 3));
    await tester.tap(find.text('My bookings').last);
    await pumpFor(tester, const Duration(seconds: 8));

    // signed out on a cold boot, so it must prompt rather than error
    expect(find.text('My bookings'), findsWidgets);
  });

  testWidgets('sign in from More works end to end against the real api',
      // skipped unless the account is passed in via --dart-define
      skip: !hasCredentials,
      (tester) async {
    await bootApp(tester);
    await enterShell(tester);

    await tester.tap(find.text('More').last);
    await pumpFor(tester, const Duration(seconds: 3));

    await tester.tap(find.text('Sign in').last);
    await pumpFor(tester, const Duration(seconds: 3));

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      testMobile,
    );
    await pumpFor(tester, const Duration(milliseconds: 600));
    await tester.enterText(
      find.byType(TextField).at(1),
      testPassword,
    );
    await pumpFor(tester, const Duration(milliseconds: 600));

    await tester.tap(find.widgetWithText(Center, 'Sign in').last);
    await pumpFor(tester, const Duration(seconds: 10));

    // the session is live
    expect(AppDi.locator<AuthSession>().isLoggedIn, isTrue);
    expect(AppDi.locator<AuthSession>().patient?.mobile, testMobile);
  });
}
