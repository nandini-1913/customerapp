import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/auth_models.dart';
import '../../services/auth_service.dart';
import '../../services/mock_auth_service.dart';
import '../widgets/auth_headers.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';
import '../widgets/social_auth_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _auth;

  bool _loading = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? MockAuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await _auth.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      _enterApp(result.user);
    } else {
      _showError(result.message ?? 'Sign in failed');
    }
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    final result = await _auth.signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (result.success) {
      _enterApp(result.user);
    } else {
      _showError(result.message ?? 'Google sign-in failed');
    }
  }

  Future<void> _guest() async {
    final result = await _auth.continueAsGuest();
    if (!mounted) return;
    if (result.success) {
      _enterApp(result.user);
    }
  }

  void _enterApp(AuthUser? user) {
    if (user != null) {
      context.read<SessionController>().setFromAuth(user);
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.homePlaceholder,
      (_) => false,
    );
  }

  Future<void> _mobileOtp() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final mobile = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.space6,
            right: AppSpacing.space6,
            top: AppSpacing.space6,
            bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.space6,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login with Mobile OTP',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  'Enter your mobile number to receive a verification code.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.space5),
                AuthTextField(
                  label: 'Mobile Number',
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                  validator: AuthValidators.mobile,
                ),
                const SizedBox(height: AppSpacing.space5),
                AuthPrimaryButton(
                  label: 'Send OTP',
                  icon: Icons.sms_rounded,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
    if (mobile == null || !mounted) return;

    await _auth.sendOtp(mobileNumber: mobile);
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppRoutes.otpVerification,
      arguments: OtpVerificationArgs(
        contactDisplay: AuthValidators.formatMobileDisplay(mobile),
        purpose: OtpPurpose.mobileLogin,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AuthTopAccentBar(),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space6,
                  AppSpacing.space8,
                  AppSpacing.space6,
                  AppSpacing.space8,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthBrandHeader(),
                      const SizedBox(height: AppSpacing.space4),
                      Text('Welcome Back', style: theme.textTheme.headlineLarge),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        'Sign in to continue to your account',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      AuthTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.email_rounded,
                        validator: AuthValidators.email,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      AuthTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        showVisibilityToggle: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.lock_rounded,
                        validator: AuthValidators.password,
                        autofillHints: const [AutofillHints.password],
                        onChanged: (_) {},
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.forgotPassword),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      AuthPrimaryButton(
                        label: _loading ? 'Signing in…' : 'Sign In',
                        icon: Icons.login_rounded,
                        loading: _loading,
                        onPressed: _signIn,
                      ),
                      const SizedBox(height: AppSpacing.space5),
                      const AuthOrDivider(),
                      const SizedBox(height: AppSpacing.space5),
                      GoogleSignInButton(
                        label: 'Continue with Google',
                        loading: _googleLoading,
                        onPressed: _google,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      SocialAuthButton(
                        label: 'Login with Mobile OTP',
                        icon: Icons.phone_android_rounded,
                        onPressed: _mobileOtp,
                      ),
                      const SizedBox(height: AppSpacing.space5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(AppRoutes.createAccount),
                            child: const Text('Create Account'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Material(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.mdAll,
                        child: InkWell(
                          onTap: _guest,
                          borderRadius: AppRadius.mdAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space4,
                              vertical: AppSpacing.space3,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.mdAll,
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.space3),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Continue as Guest',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Browse products · Cannot request quotes or save wishlist',
                                        style: AppTypography.caption(
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.outlineVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
