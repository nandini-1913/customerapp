import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
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
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: !_isLast
                              ? TextButton(
                                  onPressed: _goLogin,
                                  child: Text(
                                    'Skip',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppColors.outline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 48),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: OnboardingIllustration(index: _index),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 24, 32, 20),
                        child: Column(
                          children: [
                            Text(
                              slide.headline,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(height: 1.25),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              slide.desc,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(height: 1.65),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
                                      horizontal: 4,
                                    ),
                                    height: 8,
                                    width: active ? 28 : 8,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.primary
                                          : AppColors.outlineVariant,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 20),
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
                                      width: 52,
                                      height: 52,
                                      child: Material(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(14),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: () => setState(() => _index--),
                                          child: const Icon(
                                            Icons.arrow_back_rounded,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
