import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/onboarding_illustrations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _slides = [
    (
      headline: 'Discover Thousands of Construction Products',
      desc:
          'Browse products from leading brands across cement, steel, pipes, paints, electricals, sanitaryware, hardware, construction chemicals, road materials and much more.',
    ),
    (
      headline: 'Compare & Request Quotations',
      desc:
          'Compare specifications, check availability, download catalogues and request quotations from your preferred dealer.',
    ),
    (
      headline: 'Trusted Brands. Trusted Dealers.',
      desc:
          'Locate dealers, save favourites, manage enquiries and build your projects with confidence.',
    ),
  ];

  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  void _goLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slide = _slides[_index];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space5,
                          AppSpacing.space3,
                          AppSpacing.space5,
                          AppSpacing.space2,
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: !_isLast
                              ? TextButton(
                                  onPressed: _goLogin,
                                  child: Text(
                                    'Skip',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: AppSpacing.space12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space6,
                          vertical: AppSpacing.space4,
                        ),
                        child: OnboardingIllustration(index: _index),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space8,
                          AppSpacing.space6,
                          AppSpacing.space8,
                          AppSpacing.space5,
                        ),
                        child: Column(
                          children: [
                            Text(
                              slide.headline,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            Text(
                              slide.desc,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space6,
                          0,
                          AppSpacing.space6,
                          AppSpacing.space8,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_slides.length, (i) {
                                final active = i == _index;
                                return GestureDetector(
                                  onTap: () => setState(() => _index = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.space1,
                                    ),
                                    height: AppSpacing.space2,
                                    width: active
                                        ? AppSpacing.space8
                                        : AppSpacing.space2,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.primary
                                          : AppColors.outlineVariant,
                                      borderRadius: AppRadius.xsAll,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: AppSpacing.space5),
                            if (_isLast)
                              AuthPrimaryButton(
                                label: 'Get Started',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: _goLogin,
                              )
                            else
                              Row(
                                children: [
                                  if (_index > 0) ...[
                                    SizedBox(
                                      width: AppSpacing.buttonHeight,
                                      height: AppSpacing.buttonHeight,
                                      child: Material(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: AppRadius.mdAll,
                                        child: InkWell(
                                          borderRadius: AppRadius.mdAll,
                                          onTap: () => setState(() => _index--),
                                          child: const Icon(
                                            Icons.arrow_back_rounded,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.space3),
                                  ],
                                  Expanded(
                                    child: AuthPrimaryButton(
                                      label: 'Next',
                                      icon: Icons.arrow_forward_rounded,
                                      onPressed: () {
                                        if (_isLast) {
                                          _goLogin();
                                        } else {
                                          setState(() => _index++);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
