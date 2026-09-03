import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_filter_sheet.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

class ProductListScreen extends StatefulWidget {
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
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late CatalogFilterState _filter;

  @override
  void initState() {
    super.initState();
    _filter = CatalogFilterState(subCategoryId: widget.subCategoryId);
  }

  List<CatalogProduct> _baseProducts() {
    if (widget.subCategoryId != null) {
      return CatalogMockData.productsBySubCategory(widget.subCategoryId!);
    }
    if (widget.categoryId != null) {
      return CatalogMockData.productsByCategory(widget.categoryId!);
    }
    if (widget.title == 'Featured Products') {
      return CatalogMockData.featuredProducts;
    }
    if (widget.title == 'Popular Products') {
      return CatalogMockData.popularProducts;
    }
    if (widget.title == 'Recently Viewed') {
      return const [];
    }
    return CatalogMockData.products;
  }

  Future<void> _openFilters() async {
    final categoryId = widget.categoryId ??
        (widget.subCategoryId != null
            ? CatalogMockData.subCategoryById(widget.subCategoryId!)?.categoryId
            : null);
    final result = await showCatalogFilterSheet(
      context: context,
      initial: _filter,
      categoryId: categoryId,
      subCategories: categoryId == null
          ? const []
          : CatalogMockData.subCategoriesFor(categoryId),
      brands: categoryId == null
          ? CatalogMockData.brands
          : CatalogMockData.brandsForCategory(categoryId),
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Brand pages show brand-specific variants; others show base products.
    if (widget.brandId != null) {
      final variants = CatalogMockData.variantsByBrand(widget.brandId!);
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Text(widget.title ?? 'Brand products'),
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

    final products = CatalogMockData.filterProducts(
      source: _baseProducts(),
      subCategoryId: _filter.subCategoryId,
      brandId: _filter.brandId,
      size: _filter.size,
      material: _filter.material,
      sort: _filter.sort,
    );

    final showFilter = widget.brandId == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.title ?? 'Products'),
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
      floatingActionButton: showFilter
          ? FloatingActionButton.extended(
              onPressed: _openFilters,
              icon: const Icon(Icons.tune_rounded),
              label: Text(
                _filter.hasActiveFilters ? 'Filter · On' : 'Filter / Sort',
              ),
            )
          : null,
      body: products.isEmpty
          ? const Center(child: Text('No products found'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space4,
                AppSpacing.space4,
                AppSpacing.space4,
                AppSpacing.space16,
              ),
              itemCount: products.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.space3),
              itemBuilder: (context, index) {
                final product = products[index];
                final variants = CatalogMockData.variantsByProduct(product.id);
                final from = CatalogMockData.cheapestVariantFor(product.id);
                final brandName = from?.brandName ?? product.subCategoryName;
                final inStock = from?.inStock ?? true;

                return Material(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgAll,
                  child: InkWell(
                    borderRadius: AppRadius.lgAll,
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
                                borderRadius: AppRadius.mdAll,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: AppSpacing.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      brandName,
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
                                    const SizedBox(height: AppSpacing.space1),
                                    StockStatusChip(inStock: inStock),
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
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
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
                    borderRadius: AppRadius.mdAll,
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
                        Text(
                          variant.productName,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          variant.specSummary,
                          style: theme.textTheme.bodySmall,
                        ),
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
