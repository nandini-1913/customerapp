import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/auth_models.dart';
import '../../services/auth_service.dart';
import '../../services/mock_auth_service.dart';
import '../widgets/auth_headers.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';
import '../widgets/role_selector.dart';
import '../widgets/social_auth_buttons.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late final AuthService _auth;
  UserRole? _role;
  bool _acceptedTerms = false;
  bool _loading = false;
  bool _googleLoading = false;
  String? _roleError;
  String? _termsError;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? MockAuthService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _roleError = _role == null ? 'Please select your role' : null;
      _termsError = !_acceptedTerms ? 'Please accept the Terms and Privacy Policy' : null;
    });

    final valid = _formKey.currentState!.validate();
    if (!valid || _role == null || !_acceptedTerms) return;

    setState(() => _loading = true);
    final result = await _auth.register(
      RegisterRequest(
        fullName: _nameController.text.trim(),
        businessName: _businessController.text.trim().isEmpty
            ? null
            : _businessController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        password: _passwordController.text,
        role: _role!,
      ),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await _auth.sendOtp(mobileNumber: _mobileController.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppRoutes.otpVerification,
      arguments: OtpVerificationArgs(
        contactDisplay:
            AuthValidators.formatMobileDisplay(_mobileController.text),
        purpose: OtpPurpose.registration,
      ),
    );
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    final result = await _auth.signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (result.success) {
      if (result.user != null) {
        context.read<SessionController>().setFromAuth(result.user!);
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.homePlaceholder,
        (_) => false,
      );
    }
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space5,
                      AppSpacing.space6,
                      AppSpacing.space3,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: AppSpacing.space1),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: theme.textTheme.headlineSmall,
                              ),
                              Text(
                                'Join thousands of construction professionals',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.space6,
                        0,
                        AppSpacing.space6,
                        AppSpacing.space8,
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              label: 'Full Name',
                              controller: _nameController,
                              prefixIcon: Icons.person_rounded,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidators.fullName,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            AuthTextField(
                              label: 'Business Name (Optional)',
                              controller: _businessController,
                              prefixIcon: Icons.business_rounded,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            AuthTextField(
                              label: 'Email Address',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_rounded,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidators.email,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            AuthTextField(
                              label: 'Mobile Number',
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_rounded,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidators.mobile,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            AuthTextField(
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: true,
                              showVisibilityToggle: true,
                              prefixIcon: Icons.lock_rounded,
                              textInputAction: TextInputAction.next,
                              validator: AuthValidators.password,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            AuthTextField(
                              label: 'Confirm Password',
                              controller: _confirmController,
                              obscureText: true,
                              showVisibilityToggle: true,
                              prefixIcon: Icons.lock_rounded,
                              textInputAction: TextInputAction.done,
                              validator: (v) => AuthValidators.confirmPassword(
                                v,
                                _passwordController.text,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            RoleSelector(
                              value: _role,
                              errorText: _roleError,
                              onChanged: (role) {
                                setState(() {
                                  _role = role;
                                  _roleError = null;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _acceptedTerms = !_acceptedTerms;
                                  _termsError = null;
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: AppSpacing.space5,
                                    height: AppSpacing.space5,
                                    margin: const EdgeInsets.only(
                                      top: AppSpacing.space1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _acceptedTerms
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: AppRadius.smAll,
                                      border: Border.all(
                                        color: _termsError != null
                                            ? AppColors.error
                                            : _acceptedTerms
                                                ? AppColors.primary
                                                : AppColors.outlineVariant,
                                        width: 2,
                                      ),
                                    ),
                                    child: _acceptedTerms
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: AppSpacing.space4,
                                            color: AppColors.onPrimary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: AppSpacing.space3),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: const [
                                          TextSpan(text: 'I accept the '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_termsError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.space2,
                                  left: AppSpacing.space8,
                                ),
                                child: Text(
                                  _termsError!,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: AppColors.error),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.space4),
                            AuthPrimaryButton(
                              label: 'Create Account',
                              icon: Icons.person_add_rounded,
                              loading: _loading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            GoogleSignInButton(
                              label: 'Sign up with Google',
                              loading: _googleLoading,
                              onPressed: _google,
                            ),
                            const SizedBox(height: AppSpacing.space4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Login'),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
