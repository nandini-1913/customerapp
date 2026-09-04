import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

/// Pipes & Tubing category — sidebar subcategories + single summary card per type.
///
/// Flow: select sidebar item (All / UPVC / CPVC / …) → one product card → tap → pipe list.
class PipesTubingBrowseScreen extends StatefulWidget {
  const PipesTubingBrowseScreen({super.key});

  @override
  State<PipesTubingBrowseScreen> createState() =>
      _PipesTubingBrowseScreenState();
}

class _PipesTubingBrowseScreenState extends State<PipesTubingBrowseScreen> {
  /// `null` = All pipe types.
  String? _selectedSubCategoryId;

  void _openPipeConfigurator({required String? subCategoryId}) {
    Navigator.of(context).pushNamed(
      AppRoutes.upvcPipeVariants,
      arguments: UpvcPipeVariantsArgs(subCategoryId: subCategoryId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category =
        CatalogMockData.categoryById(CatalogMockData.pipesTubingCategoryId);
    final subs =
        CatalogMockData.subCategoriesFor(CatalogMockData.pipesTubingCategoryId);
    SubCategory? selectedSub;
    if (_selectedSubCategoryId != null) {
      for (final sub in subs) {
        if (sub.id == _selectedSubCategoryId) {
          selectedSub = sub;
          break;
        }
      }
      selectedSub ??= subs.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(category?.name ?? 'Pipes & Tubing'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PipeSubCategorySidebar(
            subCategories: subs,
            selectedId: _selectedSubCategoryId,
            onSelected: (id) => setState(() => _selectedSubCategoryId = id),
          ),
          Expanded(
            child: _PipeSummaryPanel(
              subCategory: selectedSub,
              onOpenList: () => _openPipeConfigurator(
                subCategoryId: _selectedSubCategoryId,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipeSubCategorySidebar extends StatelessWidget {
  const _PipeSubCategorySidebar({
    required this.subCategories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<SubCategory> subCategories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final category =
        CatalogMockData.categoryById(CatalogMockData.pipesTubingCategoryId);

    return Material(
      color: AppColors.surface,
      child: SizedBox(
        width: 96,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
          itemCount: subCategories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space2),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SidebarTile(
                label: 'All',
                imageAsset: CatalogMockData.pipeAllThumbnailAsset,
                fallbackIcon: category?.icon ?? 'plumbing',
                selected: selectedId == null,
                onTap: () => onSelected(null),
              );
            }

            final sub = subCategories[index - 1];
            return _SidebarTile(
              label: CatalogMockData.pipeSubCategoryDisplayName(sub),
              imageAsset: CatalogMockData.pipeSubCategoryImageAsset(sub.id),
              fallbackIcon: category?.icon ?? 'plumbing',
              selected: selectedId == sub.id,
              onTap: () => onSelected(sub.id),
            );
          },
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.label,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imageAsset;
  final String fallbackIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space2,
          vertical: AppSpacing.space1,
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: selected ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CategoryImage(
                imageAsset: imageAsset,
                fallbackIcon: fallbackIcon,
                fallbackIconColor: AppColors.primary,
                fallbackBackground: AppColors.surfaceContainer,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                iconSize: AppSpacing.space5,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipeSummaryPanel extends StatelessWidget {
  const _PipeSummaryPanel({
    required this.subCategory,
    required this.onOpenList,
  });

  final SubCategory? subCategory;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAll = subCategory == null;
    final isUpvc = subCategory != null &&
        CatalogMockData.isUpvcPipesSubCategory(subCategory!.id);

    final variants = isAll
        ? CatalogMockData.variantsByCategory(
            CatalogMockData.pipesTubingCategoryId,
          )
        : isUpvc
            ? CatalogMockData.upvcPipeVariants
            : CatalogMockData.variants
                .where((v) => v.subCategoryId == subCategory!.id)
                .toList();

    final products = isAll
        ? CatalogMockData.productsByCategory(CatalogMockData.pipesTubingCategoryId)
        : CatalogMockData.productsBySubCategory(subCategory!.id);

    final optionCount = variants.isNotEmpty ? variants.length : products.length;

    ProductVariant? cheapest;
    for (final variant in variants) {
      if (cheapest == null) {
        cheapest = variant;
        continue;
      }
      if (variant.inStock && !cheapest.inStock) {
        cheapest = variant;
        continue;
      }
      if (variant.inStock == cheapest.inStock && variant.price < cheapest.price) {
        cheapest = variant;
      }
    }

    final category =
        CatalogMockData.categoryById(CatalogMockData.pipesTubingCategoryId);
    final title = isAll
        ? 'Pipes & Tubing'
        : '${subCategory!.name} Pipes';
    final subtitle = isAll
        ? 'UPVC, CPVC, HDPE and SWR · multiple brands and sizes'
        : isUpvc
            ? 'Schedule 40 & 80 · multiple brands and sizes'
            : '${subCategory!.name} · multiple brands and sizes';

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          Text(
            'Tap the product to view all sizes and brands',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          _PipeSummaryCard(
            title: title,
            subtitle: subtitle,
            imageAsset: CatalogMockData.pipeSummaryImageAsset,
            fallbackIcon: category?.icon ?? 'plumbing',
            cheapestVariant: cheapest,
            optionCount: optionCount,
            onTap: onOpenList,
          ),
        ],
      ),
    );
  }
}

class _PipeSummaryCard extends StatelessWidget {
  const _PipeSummaryCard({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.optionCount,
    required this.onTap,
    this.cheapestVariant,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final String fallbackIcon;
  final int optionCount;
  final ProductVariant? cheapestVariant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = cheapestVariant;
    final hasDiscount = variant?.mrp != null &&
        variant!.sellingPrice != null &&
        variant.mrp! > variant.sellingPrice!;

    return Material(
      color: AppColors.surface,
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadow,
      borderRadius: AppRadius.lgAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: AppColors.divider),
                ),
                child: CategoryImage(
                  imageAsset: imageAsset,
                  fallbackIcon: fallbackIcon,
                  fallbackIconColor: AppColors.primary,
                  fallbackBackground: AppColors.surfaceContainer,
                  height: 180,
                  fit: BoxFit.contain,
                  borderRadius: AppRadius.mdAll,
                  iconSize: AppSpacing.space8,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              if (variant != null) ...[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: AppSpacing.space2,
                  runSpacing: AppSpacing.space1,
                  children: [
                    Text(
                      variant.sellingPriceLabel ?? variant.priceLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '/ ${variant.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                    if (hasDiscount) ...[
                      Text(
                        variant.mrpLabel ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.space2,
                          vertical: AppSpacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Text(
                          variant.discountPercentLabel ?? '',
                          style: AppTypography.caption(
                            color: AppColors.success,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.space2),
                StockStatusChip(status: variant.stockStatus),
                const SizedBox(height: AppSpacing.space2),
              ],
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('VIEW'),
                        Text(
                          '$optionCount options',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.primary,
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
