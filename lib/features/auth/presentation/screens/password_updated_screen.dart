import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/password_success_illustration.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 56),
          child: Column(
            children: [
              const Spacer(),
              const PasswordSuccessIllustration(),
              Transform.translate(
                offset: const Offset(0, -16),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 36,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Password Updated\nSuccessfully',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Your password has been changed successfully. You can now sign in with your new password.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.65),
              ),
              const SizedBox(height: 40),
              AuthPrimaryButton(
                label: 'Go to Login',
                icon: Icons.login_rounded,
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'SHIVANI CONSTRUCTIONS · SECURE ✓',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  color: AppColors.outline,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
