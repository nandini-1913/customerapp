import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_icons.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.onTap,
    this.onVoice,
    this.onScan,
  });

  final VoidCallback? onTap;
  final VoidCallback? onVoice;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      elevation: AppElevation.level2,
      shadowColor: AppColors.shadow,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Container(
          height: AppSpacing.space14,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
            color: AppColors.surface,
          ),
          child: Row(
            children: [
              Icon(appIcon('search'), color: AppColors.primary),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  'Search products, brands or categories',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onVoice ?? onTap,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.space8,
                  minHeight: AppSpacing.space8,
                ),
                icon: Icon(appIcon('mic'), color: AppColors.onSurfaceVariant),
              ),
              IconButton(
                onPressed: onScan ?? onTap,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.space8,
                  minHeight: AppSpacing.space8,
                ),
                icon: Icon(
                  appIcon('qr_code_scanner'),
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
