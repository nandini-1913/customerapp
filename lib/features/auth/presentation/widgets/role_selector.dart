import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/auth_models.dart';

IconData roleIcon(UserRole role) {
  return switch (role) {
    UserRole.dealer => Icons.storefront_rounded,
    UserRole.builder => Icons.construction_rounded,
    UserRole.contractor => Icons.handyman_rounded,
    UserRole.individualCustomer => Icons.person_rounded,
  };
}

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final UserRole? value;
  final ValueChanged<UserRole> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupMenuButton<UserRole>(
          onSelected: onChanged,
          offset: const Offset(0, 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
          ),
          color: AppColors.surface,
          itemBuilder: (context) => UserRole.values
              .map(
                (role) => PopupMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(
                        roleIcon(role),
                        size: 18,
                        color: value == role
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          role.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                value == role ? FontWeight.w600 : FontWeight.w400,
                            color: value == role
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (value == role)
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
          child: Container(
            height: AppSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.outlineVariant,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.badge_rounded,
                  size: 20,
                  color: hasError ? AppColors.error : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I am a',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: hasError
                              ? AppColors.error
                              : AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        value?.label ?? 'Select your role',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: value != null
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_rounded, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
