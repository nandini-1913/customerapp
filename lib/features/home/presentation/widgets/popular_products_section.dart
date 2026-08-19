import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../../catalog/data/mock/catalog_mock_data.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import 'home_section_header.dart';

class PopularProductsSection extends StatelessWidget {
  const PopularProductsSection({
    super.key,
    required this.products,
    this.onViewAll,
    this.onProductTap,
  });

  final List<CatalogProduct> products;
  final VoidCallback? onViewAll;
  final void Function(CatalogProduct product)? onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HomeSectionHeader(title: 'Popular Products', onViewAll: onViewAll),
        const SizedBox(height: AppSpacing.space3),
        for (var i = 0; i < products.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.space3),
          ProductListCard(
            product: products[i],
            onTap: () => onProductTap?.call(products[i]),
          ),
        ],
      ],
    );
  }
}

class ProductListCard extends StatelessWidget {
  const ProductListCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final CatalogProduct product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandCount = CatalogMockData.variantsByProduct(product.id).length;
    final from = CatalogMockData.cheapestVariantFor(product.id);

    return Material(
      color: AppColors.surface,
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: const BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryImage(
                    imageAsset: product.imageAsset,
                    fallbackIcon: product.icon,
                    fallbackIconColor: AppColors.primary,
                    fallbackBackground: AppColors.surfaceContainer,
                    width: AppSpacing.space12,
                    height: AppSpacing.space12,
                    borderRadius: AppRadius.mdAll,
                    fit: BoxFit.cover,
                    iconSize: AppSpacing.space6,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.categoryName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          '${product.subCategoryName} · $brandCount brands',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          product.specSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        Text(
                          from == null
                              ? product.priceWithUnit
                              : 'From ${from.priceWithUnit}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              ProductActionBar(product: product, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
