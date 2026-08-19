import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
    this.categoryId,
    this.subCategoryId,
    this.brandId,
    this.title,
  });

  final String? categoryId;
  final String? subCategoryId;
  final String? brandId;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Brand pages show brand-specific variants; others show base products.
    if (brandId != null) {
      final variants = CatalogMockData.variantsByBrand(brandId!);
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(title ?? 'Brand products'),
        ),
        body: variants.isEmpty
            ? const Center(child: Text('No products found'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.space4),
                itemCount: variants.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.space3),
                itemBuilder: (context, index) {
                  final variant = variants[index];
                  return _VariantTile(variant: variant);
                },
              ),
      );
    }

    List<CatalogProduct> products;
    if (subCategoryId != null) {
      products = CatalogMockData.productsBySubCategory(subCategoryId!);
    } else if (categoryId != null) {
      products = CatalogMockData.productsByCategory(categoryId!);
    } else if (title == 'Featured Products') {
      products = CatalogMockData.featuredProducts;
    } else if (title == 'Popular Products') {
      products = CatalogMockData.popularProducts;
    } else if (title == 'Recently Viewed') {
      products = const [];
    } else {
      products = CatalogMockData.products;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(title ?? 'Products'),
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.space4),
              itemCount: products.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.space3),
              itemBuilder: (context, index) {
                final product = products[index];
                final variants =
                    CatalogMockData.variantsByProduct(product.id);
                final from = CatalogMockData.cheapestVariantFor(product.id);

                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.productDetail,
                        arguments: ProductDetailArgs(productId: product.id),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                borderRadius: BorderRadius.circular(12),
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: AppSpacing.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.subCategoryName,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      product.name,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    Text(
                                      product.specSummary,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: AppSpacing.space1),
                                    Text(
                                      '${variants.length} brands available',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: AppColors.outline),
                                    ),
                                    const SizedBox(height: AppSpacing.space2),
                                    Text(
                                      from == null
                                          ? product.priceWithUnit
                                          : 'From ${from.priceWithUnit}',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
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
              },
            ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({required this.variant});

  final ProductVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.productDetail,
            arguments: ProductDetailArgs(
              productId: variant.productId,
              variantId: variant.id,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryImage(
                    imageAsset: variant.imageAsset,
                    fallbackIcon: variant.icon,
                    fallbackIconColor: AppColors.primary,
                    fallbackBackground: AppColors.surfaceContainer,
                    width: AppSpacing.space12,
                    height: AppSpacing.space12,
                    borderRadius: BorderRadius.circular(12),
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.brandName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(variant.productName, style: theme.textTheme.titleSmall),
                        Text(variant.specSummary, style: theme.textTheme.bodySmall),
                        const SizedBox(height: AppSpacing.space2),
                        Row(
                          children: [
                            Text(
                              variant.priceWithUnit,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            StockStatusChip(inStock: variant.inStock),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),
              VariantActionBar(variant: variant, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
