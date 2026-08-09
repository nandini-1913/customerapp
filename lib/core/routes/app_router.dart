import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/auth_home_placeholder_screen.dart';
import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/password_updated_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _fade(const OnboardingScreen(), settings);
      case AppRoutes.login:
        return _slide(const LoginScreen(), settings);
      case AppRoutes.createAccount:
        return _slide(const CreateAccountScreen(), settings);
      case AppRoutes.otpVerification:
        final args = settings.arguments as OtpVerificationArgs?;
        return _slide(
          OtpVerificationScreen(
            args: args ??
                const OtpVerificationArgs(
                  contactDisplay: '+91 98765 43210',
                  purpose: OtpPurpose.mobileLogin,
                ),
          ),
          settings,
        );
      case AppRoutes.forgotPassword:
        return _slide(const ForgotPasswordScreen(), settings);
      case AppRoutes.resetPassword:
        final args = settings.arguments as ResetPasswordArgs?;
        return _slide(
          ResetPasswordScreen(
            args: args ??
                const ResetPasswordArgs(
                  identifier: '',
                  isEmail: true,
                ),
          ),
          settings,
        );
      case AppRoutes.passwordUpdated:
        return _fade(const PasswordUpdatedScreen(), settings);
      case AppRoutes.homePlaceholder:
        return _fade(const AuthHomePlaceholderScreen(), settings);
      default:
        return _fade(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }
}
