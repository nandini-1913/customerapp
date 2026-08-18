import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/construction_splash_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space8,
            vertical: AppSpacing.space10,
          ),
          child: Column(
            children: [
              const Spacer(),
              const ConstructionSplashIllustration(),
              const SizedBox(height: AppSpacing.space10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.headlineLarge,
                  children: [
                    TextSpan(
                      text: 'Shivani',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' Constructions',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    const TextSpan(text: '${AppConstants.taglinePrefix} '),
                    TextSpan(
                      text: AppConstants.taglineEmphasis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const SizedBox(
                width: AppSpacing.space8,
                height: AppSpacing.space8,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                AppConstants.appVersion,
                style: AppTypography.labelSmallMono(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
