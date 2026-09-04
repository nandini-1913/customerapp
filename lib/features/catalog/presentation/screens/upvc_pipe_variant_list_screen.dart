import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/state/cart_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/catalog_widgets.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

/// Simple pipe configurator — size chips, brand/type dropdowns, live pricing.
class UpvcPipeVariantListScreen extends StatefulWidget {
  const UpvcPipeVariantListScreen({super.key, this.subCategoryId});

  final String? subCategoryId;

  @override
  State<UpvcPipeVariantListScreen> createState() =>
      _UpvcPipeVariantListScreenState();
}

class _UpvcPipeVariantListScreenState extends State<UpvcPipeVariantListScreen> {
  String? _brandId;
  String? _size;
  String? _pipeType;
  late final List<ProductVariant> _all;

  @override
  void initState() {
    super.initState();
    _all = CatalogMockData.pipeVariantsForSubCategory(widget.subCategoryId);
    final initial = _cheapestVariant(_all);
    if (initial != null) {
      _brandId = initial.brandId;
      _size = initial.specifications['Size'];
      _pipeType = initial.pipeType;
    }
  }

  List<ProductVariant> _pool({
    String? brandId,
    String? size,
    String? pipeType,
  }) {
    return CatalogMockData.filterPipeVariants(
      source: _all,
      brandId: brandId,
      size: size,
      pipeType: pipeType,
    );
  }

  List<String> _sizeOptions() => _all
      .map((v) => v.specifications['Size'] ?? '')
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> _brandOptions() => _all
      .map((v) => v.brandId)
      .toSet()
      .toList()
    ..sort((a, b) => _brandName(a).compareTo(_brandName(b)));

  List<String> _typeOptions() => _all
      .map((v) => v.pipeType ?? '')
      .where((t) => t.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  String _brandName(String brandId) =>
      CatalogMockData.brandById(brandId)?.name ?? brandId;

  /// Best match for current filters; honors explicit type before looser fallbacks.
  ProductVariant? get _resolvedVariant {
    if (_all.isEmpty) return null;

    final exact = _pool(
      brandId: _brandId,
      size: _size,
      pipeType: _pipeType,
    );
    if (exact.isNotEmpty) return exact.first;

    if (_pipeType != null && _pipeType!.isNotEmpty) {
      if (_brandId != null && _brandId!.isNotEmpty) {
        final match = _pool(brandId: _brandId, pipeType: _pipeType);
        if (match.isNotEmpty) return match.first;
      }
      if (_size != null && _size!.isNotEmpty) {
        final match = _pool(size: _size, pipeType: _pipeType);
        if (match.isNotEmpty) return match.first;
      }
      final byType = _pool(pipeType: _pipeType);
      if (byType.isNotEmpty) return byType.first;
    }

    if (_brandId != null && _size != null) {
      final match = _pool(brandId: _brandId, size: _size);
      if (match.isNotEmpty) return match.first;
    }
    if (_brandId != null) {
      final match = _pool(brandId: _brandId);
      if (match.isNotEmpty) return match.first;
    }
    if (_size != null) {
      final match = _pool(size: _size);
      if (match.isNotEmpty) return match.first;
    }

    return _all.first;
  }

  ProductVariant? _cheapestVariant(List<ProductVariant> variants) {
    if (variants.isEmpty) return null;
    final inStock = variants.where((v) => v.inStock).toList();
    final pool = inStock.isNotEmpty ? inStock : variants;
    return pool.reduce(
      (a, b) => a.price <= b.price ? a : b,
    );
  }

  bool _isSizeInStock(String size) {
    final matches = _pool(
      brandId: _brandId,
      size: size,
      pipeType: _pipeType,
    );
    if (matches.isEmpty) {
      return _pool(size: size).any((v) => v.inStock);
    }
    return matches.any((v) => v.inStock);
  }

  void _selectSize(String size) => setState(() => _size = size);

  void _selectBrand(String? brandId) => setState(() => _brandId = brandId);

  void _selectType(String? type) {
    setState(() {
      _pipeType = type;
      if (type == null || type.isEmpty) return;

      var matches = _pool(brandId: _brandId, size: _size, pipeType: type);
      if (matches.isNotEmpty) return;

      matches = _pool(brandId: _brandId, pipeType: type);
      if (matches.isNotEmpty) {
        _size = matches.first.specifications['Size'];
        return;
      }

      matches = _pool(size: _size, pipeType: type);
      if (matches.isNotEmpty) {
        _brandId = matches.first.brandId;
        return;
      }

      matches = _pool(pipeType: type);
      if (matches.isNotEmpty) {
        final variant = matches.first;
        _brandId = variant.brandId;
        _size = variant.specifications['Size'];
      }
    });
  }

  void _addToCart(ProductVariant variant) {
    context.read<CartController>().addVariant(variant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${variant.displayName} added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = _resolvedVariant;
    final screenTitle =
        CatalogMockData.pipeConfiguratorScreenTitle(widget.subCategoryId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(screenTitle),
      ),
      bottomNavigationBar: _BottomActionBar(
        variant: variant,
        onAddToCart: variant == null ? null : () => _addToCart(variant),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space4,
          AppSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: AppColors.divider),
              ),
              child: CategoryImage(
                imageAsset: CatalogMockData.pipeSummaryImageAsset,
                fallbackIcon: 'plumbing',
                fallbackIconColor: AppColors.primary,
                fallbackBackground: AppColors.surfaceContainer,
                height: 220,
                fit: BoxFit.contain,
                borderRadius: AppRadius.lgAll,
                iconSize: AppSpacing.space8,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              variant == null
                  ? screenTitle
                  : CatalogMockData.pipeConfiguratorTitle(variant),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            if (variant != null) ...[
              _PricingBlock(variant: variant),
              const SizedBox(height: AppSpacing.space2),
              StockStatusChip(status: variant.stockStatus),
            ] else
              Text(
                'No pipe variants available.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
            const SizedBox(height: AppSpacing.space4),
            _SizeSection(
              sizes: _sizeOptions(),
              selected: _size,
              isSizeInStock: _isSizeInStock,
              onSelected: _selectSize,
            ),
            const SizedBox(height: AppSpacing.space3),
            _PipeDropdownField(
              label: 'Brand',
              hint: 'Select brand',
              value: _brandId,
              items: _brandOptions()
                  .map((id) => MapEntry(id, _brandName(id)))
                  .toList(),
              onChanged: _selectBrand,
            ),
            const SizedBox(height: AppSpacing.space3),
            _PipeDropdownField(
              label: 'Type',
              hint: 'Select type',
              value: _pipeType,
              items: _typeOptions().map((t) => MapEntry(t, t)).toList(),
              onChanged: _selectType,
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeSection extends StatelessWidget {
  const _SizeSection({
    required this.sizes,
    required this.selected,
    required this.isSizeInStock,
    required this.onSelected,
  });

  final List<String> sizes;
  final String? selected;
  final bool Function(String size) isSizeInStock;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (sizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            for (final size in sizes)
              _SizeChip(
                label: size,
                selected: selected == size,
                inStock: isSizeInStock(size),
                onTap: () => onSelected(size),
              ),
          ],
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.inStock,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool inStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondaryContainer
              : inStock
                  ? AppColors.surface
                  : AppColors.surfaceContainer,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected
                ? AppColors.secondary
                : inStock
                    ? AppColors.divider
                    : AppColors.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: inStock ? AppColors.onSurface : AppColors.outline,
              ),
            ),
            if (!inStock)
              Text(
                'Out of stock',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PipeDropdownField extends StatelessWidget {
  const _PipeDropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final List<MapEntry<String, String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space1,
        ),
        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          icon: const SizedBox.shrink(),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(hint),
            ),
            ...items.map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            ),
          ],
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}

class _PricingBlock extends StatelessWidget {
  const _PricingBlock({required this.variant});

  final ProductVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = variant.sellingPriceLabel ?? variant.priceLabel;
    final pp = variant.purchasePriceLabel ?? '—';
    final discount = variant.discountPercentLabel ?? '—';
    final mrp = variant.mrpLabel;
    final hasDiscount = variant.mrp != null &&
        variant.sellingPrice != null &&
        variant.mrp! > variant.sellingPrice!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space1,
          children: [
            Text(
              '$sp / ${variant.unit}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (hasDiscount && mrp != null) ...[
              Text(
                mrp,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.outline,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                '$discount OFF',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.space2),
        _PriceRow(label: 'Selling Price (SP)', value: sp, emphasized: true),
        _PriceRow(label: 'Purchase Price (PP)', value: pp),
        _PriceRow(label: 'Discount', value: discount),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space1),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.outline,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: emphasized ? AppColors.primary : AppColors.onSurface,
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.variant,
    required this.onAddToCart,
  });

  final ProductVariant? variant;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = variant?.specifications['Size'] ?? 'Select options';
    final sp = variant == null
        ? '—'
        : (variant!.sellingPriceLabel ?? variant!.priceLabel);
    final unit = variant?.unit ?? 'pcs';
    final schedule = variant == null
        ? null
        : CatalogMockData.pipeScheduleLabel(variant!);
    final pipeType = variant?.pipeType;
    final summary = [
      if (pipeType != null && pipeType.isNotEmpty) pipeType,
      if (schedule != null && schedule.isNotEmpty) schedule,
      if (size.isNotEmpty) size,
    ].where((s) => s.isNotEmpty).join(', ');

    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            AppSpacing.space3,
            AppSpacing.space4,
            AppSpacing.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      summary,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$sp / $unit',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              FilledButton(
                onPressed:
                    variant != null && variant!.inStock ? onAddToCart : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.lgAll,
                  ),
                ),
                child: const Text('Add to cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
