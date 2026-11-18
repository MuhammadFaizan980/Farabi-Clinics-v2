import 'package:flutter/material.dart';

import '../data/models/auth/otp_args_model.dart';
import '../data/models/booking/booking_models.dart';
import '../data/models/discovery/detail_args_models.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_success_screen.dart';
import '../screens/bookings/bookings_screen.dart';
import '../screens/bookings/reschedule_screen.dart';
import '../screens/detail/branch_detail_screen.dart';
import '../screens/detail/doctor_detail_screen.dart';
import '../screens/detail/service_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/support/blogs_screen.dart';
import '../screens/support/careers_screen.dart';
import '../screens/support/contact_us_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/language_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/shell/shell_screen.dart';
import '../screens/splash/splash_screen.dart';
import 'app_routes.dart';

class AppRoutesGenerator {
  AppRoutesGenerator._();

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(settings, const SplashScreen());

      case AppRoutes.languageSelection:
        return _page(settings, const LanguageSelectionScreen());

      case AppRoutes.login:
        return _page(settings, const LoginScreen());

      case AppRoutes.register:
        return _page(settings, const RegisterScreen());

      case AppRoutes.otpVerification:
        final args = settings.arguments;
        if (args is! OtpArgsModel) return _unknown(settings);
        return _page(settings, OtpVerificationScreen(args: args));

      case AppRoutes.forgotPassword:
        return _page(settings, const ForgotPasswordScreen());

      case AppRoutes.resetPassword:
        final args = settings.arguments;
        if (args is! ResetPasswordArgsModel) return _unknown(settings);
        return _page(settings, ResetPasswordScreen(args: args));

      case AppRoutes.shell:
        return _page(settings, const ShellScreen());

      case AppRoutes.doctorDetail:
        final args = settings.arguments;
        if (args is! IdArgsModel) return _unknown(settings);
        return _page(settings, DoctorDetailScreen(args: args));

      case AppRoutes.branchDetail:
        final args = settings.arguments;
        if (args is! IdArgsModel) return _unknown(settings);
        return _page(settings, BranchDetailScreen(args: args));

      case AppRoutes.serviceDetail:
        final args = settings.arguments;
        if (args is! IdArgsModel) return _unknown(settings);
        return _page(settings, ServiceDetailScreen(args: args));

      case AppRoutes.booking:
        final args = settings.arguments;
        if (args is! BookingArgsModel) return _unknown(settings);
        return _page(settings, BookingScreen(args: args));

      case AppRoutes.bookingSuccess:
        final args = settings.arguments;
        if (args is! BookingSuccessArgsModel) return _unknown(settings);
        return _page(settings, BookingSuccessScreen(args: args));

      case AppRoutes.bookings:
        return _page(settings, const BookingsScreen());

      case AppRoutes.reschedule:
        final args = settings.arguments;
        if (args is! RescheduleArgsModel) return _unknown(settings);
        return _page(settings, RescheduleScreen(args: args));

      case AppRoutes.profile:
        return _page(settings, const ProfileScreen());

      case AppRoutes.contactUs:
        return _page(settings, const ContactUsScreen());

      case AppRoutes.careers:
        return _page(settings, const CareersScreen());

      case AppRoutes.blogs:
        return _page(settings, const BlogsScreen());

      default:
        return _unknown(settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    Widget child,
  ) =>
      MaterialPageRoute<dynamic>(settings: settings, builder: (_) => child);

  static MaterialPageRoute<dynamic> _unknown(RouteSettings settings) =>
      MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (_) => const Scaffold(body: Center(child: Text('404'))),
      );
}
