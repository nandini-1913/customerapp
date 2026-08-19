import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_icons.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

class CategoryBrowseScreen extends StatelessWidget {
  const CategoryBrowseScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = CatalogMockData.categoryById(categoryId);
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: Text('Category not found')),
      );
    }

    final subs = CatalogMockData.subCategoriesFor(categoryId);
    final products = CatalogMockData.productsByCategory(categoryId);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(category.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          if (category.imageAsset.isNotEmpty) ...[
            CategoryImage(
              imageAsset: category.imageAsset,
              fallbackIcon: category.icon,
              fallbackIconColor: Color(category.iconColor),
              fallbackBackground: Color(category.iconBackground),
              height: 160,
              borderRadius: AppRadius.lgAll,
              fit: BoxFit.cover,
              iconSize: AppSpacing.space8,
            ),
            const SizedBox(height: AppSpacing.space4),
          ],
          Text(
            category.description.isEmpty
                ? 'Browse ${category.name.toLowerCase()} products'
                : category.description,
            style: theme.textTheme.bodyMedium,
          ),
          if (subs.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space5),
            Text('Subcategories', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space3),
            ...subs.map(
              (sub) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: Material(
                  color: AppColors.surface,
                  elevation: AppElevation.level1,
                  shadowColor: AppColors.shadow,
                  borderRadius: AppRadius.lgAll,
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
                    leading: Icon(appIcon(category.icon), color: AppColors.primary),
                    title: Text(sub.name),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.productList,
                        arguments: ProductListArgs(
                          categoryId: categoryId,
                          subCategoryId: sub.id,
                          title: sub.name,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space5),
          Row(
            children: [
              Expanded(
                child: Text('Products', style: theme.textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.productList,
                    arguments: ProductListArgs(
                      categoryId: categoryId,
                      title: category.name,
                    ),
                  );
                },
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          if (products.isEmpty)
            const Text('No products in this category yet.')
          else
            ...products.take(6).map(
                  (p) => _ProductTile(
                    product: p,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.productDetail,
                        arguments: ProductDetailArgs(productId: p.id),
                      );
                    },
                  ),
                ),
        ],
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
                    '${category.itemCount} items',
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

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final CatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final variants = CatalogMockData.variantsByProduct(product.id);
    final from = CatalogMockData.cheapestVariantFor(product.id);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: ListTile(
        onTap: onTap,
        leading: CategoryImage(
          imageAsset: product.imageAsset,
          fallbackIcon: product.icon,
          fallbackIconColor: AppColors.primary,
          fallbackBackground: AppColors.surfaceContainer,
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(24),
          fit: BoxFit.cover,
        ),
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          from == null
              ? '${variants.length} brands'
              : '${variants.length} brands · from ${from.priceLabel}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
