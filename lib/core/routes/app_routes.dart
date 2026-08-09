abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String passwordUpdated = '/password-updated';
  static const String homePlaceholder = '/home-placeholder';
}

/// Arguments for [AppRoutes.otpVerification].
class OtpVerificationArgs {
  const OtpVerificationArgs({
    required this.contactDisplay,
    required this.purpose,
    this.resetIdentifier,
    this.resetIsEmail = false,
  });

  /// Phone or email shown under the subtitle.
  final String contactDisplay;
  final OtpPurpose purpose;

  /// Identifier used after password-reset OTP succeeds.
  final String? resetIdentifier;
  final bool resetIsEmail;
}

enum OtpPurpose {
  registration,
  mobileLogin,
  passwordReset,
}

/// Arguments for [AppRoutes.resetPassword].
class ResetPasswordArgs {
  const ResetPasswordArgs({
    required this.identifier,
    required this.isEmail,
  });

  final String identifier;
  final bool isEmail;
}
