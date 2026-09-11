import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/catalog_models.dart';

enum PipeFilterTab { sort, size, brand }

enum PipeModuleSort {
  discount,
  priceLowHigh,
  whatsNew,
  priceHighLow,
  ratings,
}

/// Wireframe size options — left and right columns.
abstract final class PipeFilterSizes {
  static const leftColumn = [
    '15 mm',
    '20 mm',
    '25 mm',
    '32 mm',
    '40 mm',
    '50 mm',
    '65 mm',
    '80 mm',
    '100 mm',
    '150 mm',
  ];

  static const rightColumn = [
    '200 mm',
    '250 mm',
    '300 mm',
  ];

  static const all = [...leftColumn, ...rightColumn];
}

/// Wireframe brand options.
abstract final class PipeFilterBrands {
  static const names = [
    'Astral',
    'Finolex',
    'Cera',
    'Anchor',
    'king',
  ];
}

/// Bottom filter area — sheet + tab bar matching the pipes module wireframe.
class PipesFilterChrome extends StatelessWidget {
  const PipesFilterChrome({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onClose,
    required this.sort,
    required this.selectedSize,
    required this.selectedBrand,
    required this.onSortChanged,
    required this.onSizeChanged,
    required this.onBrandChanged,
  });

  final PipeFilterTab? activeTab;
  final ValueChanged<PipeFilterTab> onTabSelected;
  final VoidCallback onClose;
  final PipeModuleSort sort;
  final String? selectedSize;
  final String? selectedBrand;
  final ValueChanged<PipeModuleSort> onSortChanged;
  final ValueChanged<String?> onSizeChanged;
  final ValueChanged<String?> onBrandChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            if (activeTab != null) ...[
              const SizedBox(height: AppSpacing.space2),
              Center(
                child: _CloseButton(onPressed: onClose),
              ),
              const SizedBox(height: AppSpacing.space2),
              _FilterSheet(
                tab: activeTab!,
                sort: sort,
                selectedSize: selectedSize,
                selectedBrand: selectedBrand,
                onSortChanged: onSortChanged,
                onSizeChanged: onSizeChanged,
                onBrandChanged: onBrandChanged,
              ),
            ],
          _FilterTabBar(
            activeTab: activeTab,
            onSort: () => onTabSelected(PipeFilterTab.sort),
            onSize: () => onTabSelected(PipeFilterTab.size),
            onBrand: () => onTabSelected(PipeFilterTab.brand),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(
        side: BorderSide(color: Color(0xFFD1D5DB)),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.close_rounded, size: 20),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.tab,
    required this.sort,
    required this.selectedSize,
    required this.selectedBrand,
    required this.onSortChanged,
    required this.onSizeChanged,
    required this.onBrandChanged,
  });

  final PipeFilterTab tab;
  final PipeModuleSort sort;
  final String? selectedSize;
  final String? selectedBrand;
  final ValueChanged<PipeModuleSort> onSortChanged;
  final ValueChanged<String?> onSizeChanged;
  final ValueChanged<String?> onBrandChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.38;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space5,
                AppSpacing.space5,
                AppSpacing.space5,
                AppSpacing.space2,
              ),
              child: Text(
                _title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                child: switch (tab) {
                  PipeFilterTab.sort => _SortOptions(
                      sort: sort,
                      onChanged: onSortChanged,
                    ),
                  PipeFilterTab.size => _SizeOptions(
                      selectedSize: selectedSize,
                      onChanged: onSizeChanged,
                    ),
                  PipeFilterTab.brand => _BrandOptions(
                      selectedBrand: selectedBrand,
                      onChanged: onBrandChanged,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    switch (tab) {
      case PipeFilterTab.sort:
        return 'Sort By';
      case PipeFilterTab.size:
        return 'Size';
      case PipeFilterTab.brand:
        return 'Brands';
    }
  }
}

class _SortOptions extends StatelessWidget {
  const _SortOptions({
    required this.sort,
    required this.onChanged,
  });

  final PipeModuleSort sort;
  final ValueChanged<PipeModuleSort> onChanged;

  static const _options = [
    (PipeModuleSort.discount, 'Discount'),
    (PipeModuleSort.priceLowHigh, 'Price (lowest first)'),
    (PipeModuleSort.whatsNew, 'What’s New'),
    (PipeModuleSort.priceHighLow, 'Price (highest first)'),
    (PipeModuleSort.ratings, 'Ratings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in _options)
          _FilterOptionTile(
            label: option.$2,
            selected: sort == option.$1,
            useSquareIndicator: true,
            onTap: () => onChanged(option.$1),
          ),
      ],
    );
  }
}

class _SizeOptions extends StatelessWidget {
  const _SizeOptions({
    required this.selectedSize,
    required this.onChanged,
  });

  final String? selectedSize;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (final size in PipeFilterSizes.leftColumn)
                  _FilterOptionTile(
                    label: size,
                    selected: selectedSize == size,
                    compact: true,
                    onTap: () => onChanged(selectedSize == size ? null : size),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (final size in PipeFilterSizes.rightColumn)
                  _FilterOptionTile(
                    label: size,
                    selected: selectedSize == size,
                    compact: true,
                    onTap: () => onChanged(selectedSize == size ? null : size),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandOptions extends StatelessWidget {
  const _BrandOptions({
    required this.selectedBrand,
    required this.onChanged,
  });

  final String? selectedBrand;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final brand in PipeFilterBrands.names)
          _FilterOptionTile(
            label: brand,
            selected: selectedBrand == brand,
            onTap: () => onChanged(selectedBrand == brand ? null : brand),
          ),
      ],
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  const _FilterOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.useSquareIndicator = false,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool useSquareIndicator;
  final bool compact;

  static const _accentGreen = Color(0xFF90D151);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: compact ? AppSpacing.space2 : AppSpacing.space3,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? _accentGreen : Colors.transparent,
                shape: useSquareIndicator ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    useSquareIndicator ? BorderRadius.circular(4) : null,
                border: Border.all(
                  color: selected ? _accentGreen : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: compact ? 15 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({
    required this.activeTab,
    required this.onSort,
    required this.onSize,
    required this.onBrand,
  });

  final PipeFilterTab? activeTab;
  final VoidCallback onSort;
  final VoidCallback onSize;
  final VoidCallback onBrand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space2,
        AppSpacing.space2,
        AppSpacing.space2,
        AppSpacing.space3,
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              icon: Icons.sort_rounded,
              label: 'Sort By',
              selected: activeTab == PipeFilterTab.sort,
              onTap: onSort,
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: _FilterTab(
              icon: Icons.open_in_full_rounded,
              label: 'Size',
              selected: activeTab == PipeFilterTab.size,
              onTap: onSize,
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: _FilterTab(
              icon: Icons.sell_outlined,
              label: 'Brand',
              selected: activeTab == PipeFilterTab.brand,
              onTap: onBrand,
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.space3,
              horizontal: AppSpacing.space2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: AppColors.onBackground),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extracts numeric mm from labels like `15 mm` or raw spec values.
double? pipeSizeMmValue(String raw) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(raw.trim());
  return match != null ? double.tryParse(match.group(1)!) : null;
}

/// Whether a product variant matches a wireframe size label.
bool variantMatchesPipeSize(ProductVariant variant, String sizeLabel) {
  final targetMm = pipeSizeMmValue(sizeLabel);
  if (targetMm == null) return false;

  final specSize = variant.specifications['Size'] ?? '';
  final specMm = pipeSizeMmValue(specSize);
  if (specMm != null && specMm == targetMm) return true;

  return specSize.toLowerCase().contains('${targetMm.toInt()}');
}

/// Whether a product variant matches a wireframe brand label.
bool variantMatchesPipeBrand(ProductVariant variant, String brandName) {
  return variant.brandName.toLowerCase() == brandName.toLowerCase();
}
