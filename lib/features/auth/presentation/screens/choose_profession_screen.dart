import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/auth_models.dart';
import '../widgets/login_flow_widgets.dart';

/// Step 4 — profession selection before entering the app.
class ChooseProfessionScreen extends StatefulWidget {
  const ChooseProfessionScreen({super.key, required this.args});

  final SignupFlowArgs args;

  @override
  State<ChooseProfessionScreen> createState() => _ChooseProfessionScreenState();
}

class _ProfessionOption {
  const _ProfessionOption({
    required this.title,
    required this.subtitle,
    required this.role,
    required this.imageAsset,
  });

  final String title;
  final String subtitle;
  final UserRole role;
  final String imageAsset;
}

class _ChooseProfessionScreenState extends State<ChooseProfessionScreen> {
  static const _options = [
    _ProfessionOption(
      title: 'Contractor',
      subtitle: 'Building & construction',
      role: UserRole.contractor,
      imageAsset: 'assets/images/professions/contractor.png',
    ),
    _ProfessionOption(
      title: 'Plumber',
      subtitle: 'Pipes, bathrooms & Fittings',
      role: UserRole.dealer,
      imageAsset: 'assets/images/professions/plumber.png',
    ),
    _ProfessionOption(
      title: 'Electrician',
      subtitle: 'wiring, switches & lighting',
      role: UserRole.builder,
      imageAsset: 'assets/images/professions/electrician.png',
    ),
    _ProfessionOption(
      title: 'Flooring',
      subtitle: 'Tiles & Adhesives',
      role: UserRole.dealer,
      imageAsset: 'assets/images/professions/flooring.png',
    ),
    _ProfessionOption(
      title: 'Home Owner',
      subtitle: 'Buying for my own house',
      role: UserRole.individualCustomer,
      imageAsset: 'assets/images/professions/home_owner.png',
    ),
  ];

  int? _selectedIndex;

  void _continue() {
    if (_selectedIndex == null) return;
    final option = _options[_selectedIndex!];

    context.read<SessionController>().setFromAuth(
      AuthUser(
        id: 'user-mobile-${widget.args.mobileNumber}',
        email: '',
        fullName: widget.args.fullName,
        mobileNumber: widget.args.mobileNumber,
        role: option.role,
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.homePlaceholder,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose your profession',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.space6),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: LoginFlowColors.fieldBorder,
                  ),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    return InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: LoginFlowColors.fieldBorder,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.asset(
                                  option.imageAsset,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => ColoredBox(
                                    color: AppColors.surfaceContainer,
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 20,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space1),
                                  Text(
                                    option.subtitle,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<int>(
                              value: index,
                              groupValue: _selectedIndex,
                              activeColor: LoginFlowColors.link,
                              onChanged: (value) =>
                                  setState(() => _selectedIndex = value),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              LoginFlowContinueButton(
                label: 'Continue',
                enabled: _selectedIndex != null,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
