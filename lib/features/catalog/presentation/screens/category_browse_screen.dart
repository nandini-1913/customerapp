import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_filter_sheet.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

class CategoryBrowseScreen extends StatefulWidget {
  const CategoryBrowseScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryBrowseScreen> createState() => _CategoryBrowseScreenState();
}

class _CategoryBrowseScreenState extends State<CategoryBrowseScreen> {
  CatalogFilterState _filter = const CatalogFilterState();

  Future<void> _openFilters(Category category) async {
    final result = await showCatalogFilterSheet(
      context: context,
      initial: _filter,
      categoryId: category.id,
      subCategories: CatalogMockData.subCategoriesFor(category.id),
      brands: CatalogMockData.brandsForCategory(category.id),
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = CatalogMockData.categoryById(widget.categoryId);
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: Text('Category not found')),
      );
    }

    final theme = Theme.of(context);
    final source = CatalogMockData.productsByCategory(category.id);
    final products = CatalogMockData.filterProducts(
      source: source,
      subCategoryId: _filter.subCategoryId,
      brandId: _filter.brandId,
      size: _filter.size,
      material: _filter.material,
      sort: _filter.sort,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(category.name),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFilters(category),
        icon: const Icon(Icons.tune_rounded),
        label: Text(_filter.hasActiveFilters ? 'Filter · On' : 'Filter / Sort'),
      ),
      body: CustomScrollView(
        slivers: [
          if (category.imageAsset.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4,
                  0,
                ),
                child: CategoryImage(
                  imageAsset: category.imageAsset,
                  fallbackIcon: category.icon,
                  fallbackIconColor: Color(category.iconColor),
                  fallbackBackground: Color(category.iconBackground),
                  height: 140,
                  borderRadius: AppRadius.lgAll,
                  fit: BoxFit.cover,
                  iconSize: AppSpacing.space8,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.description.isEmpty
                        ? 'Browse ${category.name.toLowerCase()} products'
                        : category.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    '${products.length} products',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No products match these filters')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space4,
                0,
                AppSpacing.space4,
                AppSpacing.space16,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.space3,
                  crossAxisSpacing: AppSpacing.space3,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _ProductGridCard(
                      product: product,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.productDetail,
                          arguments: ProductDetailArgs(productId: product.id),
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({required this.product, required this.onTap});

  final CatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final from = CatalogMockData.cheapestVariantFor(product.id);
    final brandName = from?.brandName ?? product.subCategoryName;
    final inStock = from?.inStock ?? true;

    return Material(
      color: AppColors.surface,
      elevation: AppElevation.level1,
      shadowColor: AppColors.shadow,
      borderRadius: AppRadius.lgAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryImage(
              imageAsset: product.imageAsset,
              fallbackIcon: product.icon,
              fallbackIconColor: AppColors.primary,
              fallbackBackground: AppColors.surfaceContainer,
              height: 80,
              fit: BoxFit.cover,
              iconSize: AppSpacing.space6,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space2,
                  AppSpacing.space2,
                  AppSpacing.space2,
                  AppSpacing.space2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Text(
                            brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            product.specSummary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          Text(
                            from == null
                                ? product.priceWithUnit
                                : '${from.priceLabel} / ${product.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space1),
                          StockStatusChip(inStock: inStock),
                        ],
                      ),
                    ),
                    ProductActionBar(
                      product: product,
                      compact: true,
                      showQuote: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Categories grid used inside [MainShell] (no nested [Scaffold]).
class CategoriesTabBody extends StatelessWidget {
  const CategoriesTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: AppColors.surface,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: AppSpacing.space14,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: CategoriesGrid()),
        ],
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Categories'),
      ),
      body: const CategoriesGrid(),
    );
  }
}

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CatalogMockData.categories;
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.space4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.space3,
        crossAxisSpacing: AppSpacing.space3,
        childAspectRatio: 0.92,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Material(
          color: AppColors.surface,
          elevation: AppElevation.level1,
          shadowColor: AppColors.shadow,
          borderRadius: AppRadius.lgAll,
          child: InkWell(
            borderRadius: AppRadius.lgAll,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.categoryBrowse,
                arguments: CategoryBrowseArgs(categoryId: category.id),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CategoryImage(
                      imageAsset: category.imageAsset,
                      fallbackIcon: category.icon,
                      fallbackIconColor: Color(category.iconColor),
                      fallbackBackground: Color(category.iconBackground),
                      width: double.infinity,
                      borderRadius: AppRadius.mdAll,
                      fit: BoxFit.cover,
                      iconSize: AppSpacing.space6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${category.itemCount} products',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
