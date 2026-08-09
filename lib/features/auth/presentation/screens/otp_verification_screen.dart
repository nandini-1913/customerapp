import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/mock_auth_service.dart';
import '../widgets/auth_otp_fields.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validators.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.args,
    this.authService,
  });

  final OtpVerificationArgs args;
  final AuthService? authService;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpKey = GlobalKey<AuthOtpFieldsState>();
  late final AuthService _auth;
  late String _contact;

  String _otp = '';
  int _seconds = AppConstants.otpResendSeconds;
  Timer? _timer;
  bool _loading = false;
  String? _error;

  bool get _isPasswordReset => widget.args.purpose == OtpPurpose.passwordReset;
  bool get _isEmailReset => _isPasswordReset && widget.args.resetIsEmail;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? MockAuthService();
    _contact = widget.args.contactDisplay;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = AppConstants.otpResendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verify([String? code]) async {
    final otp = code ?? _otp;
    if (otp.length != AppConstants.otpLength) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _auth.verifyOtp(mobileNumber: _contact, otp: otp);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      setState(() => _error = result.message ?? 'Invalid OTP');
      _otpKey.currentState?.clear();
      return;
    }

    switch (widget.args.purpose) {
      case OtpPurpose.passwordReset:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.resetPassword,
          arguments: ResetPasswordArgs(
            identifier: widget.args.resetIdentifier ?? _contact,
            isEmail: widget.args.resetIsEmail,
          ),
        );
        return;
      case OtpPurpose.registration:
      case OtpPurpose.mobileLogin:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.homePlaceholder,
          (_) => false,
        );
        return;
    }
  }

  Future<void> _resend() async {
    await _auth.sendOtp(mobileNumber: _contact);
    if (!mounted) return;
    _otpKey.currentState?.clear();
    setState(() => _error = null);
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code resent (use 123456)')),
    );
  }

  Future<void> _editContact() async {
    if (_isEmailReset) {
      final controller = TextEditingController(text: _contact);
      final formKey = GlobalKey<FormState>();
      final updated = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit email address'),
            content: Form(
              key: formKey,
              child: AuthTextField(
                label: 'Email Address',
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_rounded,
                validator: AuthValidators.email,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      controller.dispose();
      if (updated == null || !mounted) return;
      setState(() {
        _contact = updated;
        _error = null;
      });
      await _auth.sendPasswordResetCode(identifier: updated, isEmail: true);
      if (!mounted) return;
      _startTimer();
      return;
    }

    final controller = TextEditingController(
      text: _contact
          .replaceAll(RegExp(r'[^\d]'), '')
          .replaceFirst(RegExp(r'^91'), ''),
    );
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit mobile number'),
          content: Form(
            key: formKey,
            child: AuthTextField(
              label: 'Mobile Number',
              controller: controller,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_rounded,
              validator: AuthValidators.mobile,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (updated == null || !mounted) return;
    setState(() {
      _contact = AuthValidators.formatMobileDisplay(updated);
      _error = null;
    });
    await _auth.sendOtp(mobileNumber: updated);
    if (!mounted) return;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _isPasswordReset ? 'Verify Code' : 'Verify Mobile Number';
    final editLabel = _isEmailReset ? 'Edit email address' : 'Edit mobile number';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
              const SizedBox(height: 28),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _isEmailReset ? Icons.mark_email_read_rounded : Icons.phone_android_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit verification code sent to',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _contact,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 60,
                child: AuthOtpFields(
                  key: _otpKey,
                  hasError: _error != null,
                  onChanged: (value) => setState(() {
                    _otp = value;
                    _error = null;
                  }),
                  onCompleted: _verify,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              Center(
                child: _seconds > 0
                    ? Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                          children: [
                            const TextSpan(text: 'Resend code in '),
                            TextSpan(
                              text: '0:${_seconds.toString().padLeft(2, '0')}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend Code'),
                      ),
              ),
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: _loading ? 'Verifying…' : 'Verify',
                icon: Icons.verified_rounded,
                loading: _loading,
                enabled: _otp.length == AppConstants.otpLength,
                onPressed: _verify,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  onPressed: _editContact,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    editLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
