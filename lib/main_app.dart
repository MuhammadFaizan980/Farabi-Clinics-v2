import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:sizer/sizer.dart';

import 'app_di.dart';
import 'data/auth_session.dart';
import 'data/base/app_base_model.dart';
import 'data/constants/app_locales.dart';
import 'data/constants/codegen_loader.g.dart';
import 'data/network/api_client.dart';
import 'router/app_navigator.dart';
import 'router/app_routes.dart';
import 'router/app_routes_generator.dart';
import 'utils/app_text_styles.dart';
import 'utils/color/app_colors.dart';

/// shared bootstrap for both flavors.
Future<void> initApp({
  required String flavorName,
  required String baseUrl,
  required bool enableLogging,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  FlavorConfig(
    name: flavorName,
    variables: {'baseUrl': baseUrl},
  );

  await AppDi.initDi(baseUrl: baseUrl, enableLogging: enableLogging);

  // no refresh endpoint exists, so an expired session has one outcome
  AppDi.locator<ApiClient>().onUnauthorised = () async {
    await AppDi.locator<AuthSession>().clear();
    AppDi.locator<AppBaseModel>().clear();
    await AppNavigator.resetTo(AppRoutes.login);
  };

  final session = AppDi.locator<AuthSession>();
  final startLocale = session.languageCode == 'ar'
      ? AppLocales.arabic
      : AppLocales.english;

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supported,
      path: AppLocales.path,
      fallbackLocale: AppLocales.english,
      startLocale: startLocale,
      assetLoader: const CodegenLoader(),
      child: const FarabiBookingApp(),
    ),
  );
}

class FarabiBookingApp extends StatelessWidget {
  const FarabiBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        title: 'Farabi Clinics',
        debugShowCheckedModeBanner: false,
        navigatorKey: getAppNavigator(),
        onGenerateRoute: AppRoutesGenerator.generate,
        initialRoute: AppRoutes.splash,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: ThemeMode.system,
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ),
      textTheme: TextTheme(
        titleLarge: AppTextStyles.h2,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
      ),
    );
  }
}
