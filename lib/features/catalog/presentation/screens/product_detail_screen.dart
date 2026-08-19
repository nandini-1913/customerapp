import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/cart_controller.dart';
import '../../../../core/state/recently_viewed_controller.dart';
import '../../../../core/state/wishlist_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialVariantId,
  });

  final String productId;
  final String? initialVariantId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  String? _selectedVariantId;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _selectedVariantId = widget.initialVariantId;
  }

  ProductVariant? get _selected {
    final variants = CatalogMockData.variantsByProduct(widget.productId);
    if (variants.isEmpty) return null;
    if (_selectedVariantId != null) {
      for (final v in variants) {
        if (v.id == _selectedVariantId) return v;
      }
    }
    return null;
  }

  void _recordView(ProductVariant variant) {
    if (_recorded) return;
    _recorded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecentlyViewedController>().add(variant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = CatalogMockData.productById(widget.productId);
    final variants = CatalogMockData.variantsByProduct(widget.productId);

    if (product == null || variants.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final selected = _selected;
    final theme = Theme.of(context);
    final wishlist = context.watch<WishlistController>();
    final cart = context.watch<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (selected != null)
            IconButton(
              onPressed: () => wishlist.toggle(selected),
              icon: Icon(
                wishlist.contains(selected.id)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: wishlist.contains(selected.id) ? AppColors.error : null,
              ),
            ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
            icon: Badge(
              isLabelVisible: cart.totalQuantity > 0,
              label: Text('${cart.totalQuantity}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          CategoryImage(
            imageAsset: product.imageAsset,
            fallbackIcon: product.icon,
            fallbackIconColor: AppColors.primary,
            fallbackBackground: AppColors.surfaceContainer,
            height: 180,
            width: double.infinity,
            borderRadius: AppRadius.lgAll,
            fit: BoxFit.cover,
            iconSize: 64,
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            product.categoryName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(product.name, style: theme.textTheme.headlineSmall),
          Text(
            '${product.subCategoryName} · SKU ${product.sku}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text('Select brand', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.space2),
          ...variants.map((v) {
            final isSelected = selected?.id == v.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: Material(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.surface,
                borderRadius: AppRadius.lgAll,
                child: InkWell(
                  borderRadius: AppRadius.lgAll,
                  onTap: () {
                    setState(() {
                      _selectedVariantId = v.id;
                      _qty = v.minimumOrderQuantity;
                      _recorded = false;
                    });
                    _recordView(v);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.brandName, style: theme.textTheme.titleSmall),
                              Text(
                                v.specSummary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              v.priceWithUnit,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            StockStatusChip(inStock: v.inStock),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (selected == null) ...[
            const SizedBox(height: AppSpacing.space3),
            Text(
              'Choose a brand to view details, set quantity, and add to cart.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.outline,
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                ...List.generate(5, (i) {
                  final filled = i < selected.rating.round();
                  return Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: filled
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
                  );
                }),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  '${selected.rating} (${selected.reviewCount})',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              selected.priceWithUnit,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(selected.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.space4),
            Text('Specifications', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.space2),
            ...selected.specifications.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space1),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        e.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(e.value, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Minimum order: ${selected.minimumOrderQuantity} ${selected.unit}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.space3),
            Row(
              children: [
                Text('Quantity', style: theme.textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  onPressed: _qty > selected.minimumOrderQuantity
                      ? () => setState(() => _qty--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_qty', style: theme.textTheme.titleMedium),
                IconButton(
                  onPressed: selected.inStock
                      ? () => setState(() => _qty++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: selected.inStock
                        ? () {
                            cart.addVariant(selected, quantity: _qty);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${selected.displayName} added to cart',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    child: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (selected.inStock &&
                          cart.quantityOf(selected.id) == 0) {
                        cart.addVariant(selected, quantity: _qty);
                      }
                      Navigator.of(context).pushNamed(AppRoutes.cart);
                    },
                    child: const Text('Get Quote'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.space8),
        ],
      ),
    );
  }
}
