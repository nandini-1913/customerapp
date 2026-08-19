import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../domain/models/home_models.dart';
import 'home_section_header.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.categories,
    this.onViewAll,
    this.onCategoryTap,
  });

  final List<HomeCategory> categories;
  final VoidCallback? onViewAll;
  final void Function(HomeCategory category)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'Categories', onViewAll: onViewAll),
        const SizedBox(height: AppSpacing.space3),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = AppSpacing.space3;
            final cardWidth = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final category in categories)
                  SizedBox(
                    width: cardWidth,
                    child: HomeCategoryCard(
                      category: category,
                      onTap: () => onCategoryTap?.call(category),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class HomeCategoryCard extends StatelessWidget {
  const HomeCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  final HomeCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadow,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space3),
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CategoryImage(
                imageAsset: category.imageAsset,
                fallbackIcon: category.icon,
                fallbackIconColor: Color(category.iconColor),
                fallbackBackground: Color(category.iconBackground),
                width: AppSpacing.space12,
                height: AppSpacing.space12,
                borderRadius: AppRadius.mdAll,
                fit: BoxFit.cover,
                iconSize: AppSpacing.space5,
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      '${category.itemCount} items',
                      style: AppTypography.caption(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
