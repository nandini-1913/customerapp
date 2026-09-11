import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/catalog_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/category_image.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';
import '../widgets/pipes_filter_panel.dart';

/// Plumbing Pipes & Fittings — sidebar sections + 2-column product grid (wireframe).
class PipesTubingBrowseScreen extends StatefulWidget {
  const PipesTubingBrowseScreen({super.key});

  @override
  State<PipesTubingBrowseScreen> createState() =>
      _PipesTubingBrowseScreenState();
}

enum _PipeModuleSection { all, pipes, fittings, bathroom }

/// Fixed sidebar thumbnails — common images only (not product-specific).
abstract final class _PipeSidebarImages {
  static const all = CatalogMockData.pipeAllThumbnailAsset;
  static const pipes = 'assets/images/pipes/single_pipe.png';
  static const fittings = 'assets/images/categories/fittings.png';
  static const bathroom = 'assets/images/categories/sanitary_wares.png';
}

class _PipeModuleSectionMeta {
  const _PipeModuleSectionMeta({
    required this.section,
    required this.label,
    required this.imageAsset,
  });

  final _PipeModuleSection section;
  final String label;
  final String imageAsset;
}

class _PipeProductGroup {
  const _PipeProductGroup({
    required this.productId,
    required this.name,
    required this.variants,
    required this.subCategoryId,
    this.commonImageAsset,
  });

  final String productId;
  final String name;
  final List<ProductVariant> variants;
  final String? subCategoryId;
  /// When set, the card shows this shared image instead of variant photos.
  final String? commonImageAsset;

  ProductVariant? get representative {
    ProductVariant? pick;
    for (final variant in variants) {
      if (pick == null) {
        pick = variant;
        continue;
      }
      if (variant.inStock && !pick.inStock) {
        pick = variant;
        continue;
      }
      final pickPrice = pick.sellingPrice ?? pick.price;
      final nextPrice = variant.sellingPrice ?? variant.price;
      if (variant.inStock == pick.inStock && nextPrice < pickPrice) {
        pick = variant;
      }
    }
    return pick;
  }

  String? get imageUrl {
    if (commonImageAsset != null) return null;
    for (final variant in variants) {
      if (variant.imageUrl != null && variant.imageUrl!.isNotEmpty) {
        return variant.imageUrl;
      }
    }
    return null;
  }

  String get imageAsset {
    if (commonImageAsset != null && commonImageAsset!.isNotEmpty) {
      return commonImageAsset!;
    }
    for (final variant in variants) {
      if (variant.imageAsset.isNotEmpty) return variant.imageAsset;
    }
    return CatalogMockData.pipeSummaryImageAsset;
  }

  double? get bestDiscountRate {
    double? max;
    for (final variant in variants) {
      final rate = variant.effectiveDiscountRate;
      if (rate == null || rate <= 0) continue;
      max = max == null ? rate : (rate > max ? rate : max);
    }
    return max;
  }

  String get discountLabel {
    final rate = bestDiscountRate;
    if (rate == null || rate <= 0) return 'discount 0%';
    return 'discount ${(rate * 100).toStringAsFixed(0)}%';
  }
}

class _PipesTubingBrowseScreenState extends State<PipesTubingBrowseScreen> {
  static const _sections = [
    _PipeModuleSectionMeta(
      section: _PipeModuleSection.all,
      label: 'ALL',
      imageAsset: _PipeSidebarImages.all,
    ),
    _PipeModuleSectionMeta(
      section: _PipeModuleSection.pipes,
      label: 'Pipes',
      imageAsset: _PipeSidebarImages.pipes,
    ),
    _PipeModuleSectionMeta(
      section: _PipeModuleSection.fittings,
      label: 'Fittings',
      imageAsset: _PipeSidebarImages.fittings,
    ),
    _PipeModuleSectionMeta(
      section: _PipeModuleSection.bathroom,
      label: 'Bathroom',
      imageAsset: _PipeSidebarImages.bathroom,
    ),
  ];

  _PipeModuleSection _section = _PipeModuleSection.all;
  PipeFilterTab? _openFilter;
  PipeModuleSort _sort = PipeModuleSort.discount;
  String? _selectedBrand;
  String? _size;

  void _openUnifiedSection(_PipeProductGroup group) {
    Navigator.of(context).pushNamed(
      AppRoutes.upvcPipeVariants,
      arguments: UpvcPipeVariantsArgs(
        subCategoryId: _configuratorSubCategoryId(_section),
        productId: null,
        title: _unifiedProductName(_section),
        heroImageAsset: _commonImageForSection(_section),
        categoryIds: _categoryIdsForSection(_section),
      ),
    );
  }

  void _openProductGroup(_PipeProductGroup group) {
    Navigator.of(context).pushNamed(
      AppRoutes.upvcPipeVariants,
      arguments: UpvcPipeVariantsArgs(
        subCategoryId: group.subCategoryId,
        productId: group.productId,
        title: group.name,
      ),
    );
  }

  List<String>? _categoryIdsForSection(_PipeModuleSection section) {
    switch (section) {
      case _PipeModuleSection.all:
        return null;
      case _PipeModuleSection.pipes:
        return [CatalogMockData.pipesTubingCategoryId];
      case _PipeModuleSection.fittings:
        return ['cat-fittings'];
      case _PipeModuleSection.bathroom:
        return ['cat-sanitary-wares', 'cat-cp-fittings'];
    }
  }

  String? _configuratorSubCategoryId(_PipeModuleSection section) {
    switch (section) {
      case _PipeModuleSection.all:
        return null;
      case _PipeModuleSection.pipes:
        return CatalogMockData.upvcPipesSubCategoryId;
      case _PipeModuleSection.fittings:
      case _PipeModuleSection.bathroom:
        return null;
    }
  }

  String _unifiedProductName(_PipeModuleSection section) {
    switch (section) {
      case _PipeModuleSection.all:
        return 'Pipes & Fittings';
      case _PipeModuleSection.pipes:
        return 'Pipes';
      case _PipeModuleSection.fittings:
        return 'Fittings';
      case _PipeModuleSection.bathroom:
        return 'Bathroom';
    }
  }

  String _commonImageForSection(_PipeModuleSection section) {
    switch (section) {
      case _PipeModuleSection.all:
        return _PipeSidebarImages.all;
      case _PipeModuleSection.pipes:
        return _PipeSidebarImages.pipes;
      case _PipeModuleSection.fittings:
        return _PipeSidebarImages.fittings;
      case _PipeModuleSection.bathroom:
        return _PipeSidebarImages.bathroom;
    }
  }

  List<ProductVariant> _moduleVariants(CatalogController catalog) {
    if (catalog.isUsingApi && catalog.pipeVariants.isNotEmpty) {
      return catalog.pipeVariants;
    }
    return CatalogMockData.variants.where((variant) {
      final id = variant.categoryId;
      return id == CatalogMockData.pipesTubingCategoryId ||
          id == 'cat-fittings' ||
          id == 'cat-sanitary-wares' ||
          id == 'cat-cp-fittings';
    }).toList();
  }

  bool _matchesSection(ProductVariant variant, _PipeModuleSection section) {
    switch (section) {
      case _PipeModuleSection.all:
        return true;
      case _PipeModuleSection.pipes:
        return variant.categoryId == CatalogMockData.pipesTubingCategoryId;
      case _PipeModuleSection.fittings:
        return variant.categoryId == 'cat-fittings';
      case _PipeModuleSection.bathroom:
        return variant.categoryId == 'cat-sanitary-wares' ||
            variant.categoryId == 'cat-cp-fittings';
    }
  }

  List<ProductVariant> _filteredVariants(CatalogController catalog) {
    var list = _moduleVariants(catalog)
        .where((v) => _matchesSection(v, _section))
        .toList();

    if (_selectedBrand != null) {
      list = list
          .where((v) => variantMatchesPipeBrand(v, _selectedBrand!))
          .toList();
    }
    if (_size != null && _size!.isNotEmpty) {
      list = list.where((v) => variantMatchesPipeSize(v, _size!)).toList();
    }

    switch (_sort) {
      case PipeModuleSort.discount:
        list.sort(
          (a, b) => (b.effectiveDiscountRate ?? 0)
              .compareTo(a.effectiveDiscountRate ?? 0),
        );
      case PipeModuleSort.priceLowHigh:
        list.sort(
          (a, b) => (a.sellingPrice ?? a.price)
              .compareTo(b.sellingPrice ?? b.price),
        );
      case PipeModuleSort.whatsNew:
        list = list.reversed.toList();
      case PipeModuleSort.priceHighLow:
        list.sort(
          (a, b) => (b.sellingPrice ?? b.price)
              .compareTo(a.sellingPrice ?? a.price),
        );
      case PipeModuleSort.ratings:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  _PipeProductGroup? _unifiedSectionGroup(List<ProductVariant> variants) {
    if (variants.isEmpty) return null;
    return _PipeProductGroup(
      productId: 'unified-${_section.name}',
      name: _unifiedProductName(_section),
      variants: variants,
      subCategoryId: _configuratorSubCategoryId(_section),
      commonImageAsset: _commonImageForSection(_section),
    );
  }

  List<_PipeProductGroup> _productGroups(List<ProductVariant> variants) {
    final map = <String, List<ProductVariant>>{};
    for (final variant in variants) {
      map.putIfAbsent(variant.productId, () => []).add(variant);
    }

    final groups = map.entries.map((entry) {
      final first = entry.value.first;
      return _PipeProductGroup(
        productId: entry.key,
        name: first.productName,
        variants: entry.value,
        subCategoryId: first.subCategoryId,
      );
    }).toList();

    groups.sort((a, b) => a.name.compareTo(b.name));
    return groups;
  }

  bool get _showAllProductsGrid => _section == _PipeModuleSection.all;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    final filtered = _filteredVariants(catalog);
    final unifiedGroup = _unifiedSectionGroup(filtered);
    final allGroups = _productGroups(filtered);
    final hasContent =
        _showAllProductsGrid ? allGroups.isNotEmpty : unifiedGroup != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _PlumbingHeader(
            onBack: () => Navigator.of(context).maybePop(),
            onSearch: () => Navigator.of(context).pushNamed(AppRoutes.search),
          ),
          Expanded(
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ModuleSidebar(
                      sections: _sections,
                      selected: _section,
                      onSelected: (section) =>
                          setState(() => _section = section),
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: AppColors.background,
                        child: catalog.isLoading && !hasContent
                            ? const Center(child: CircularProgressIndicator())
                            : !hasContent
                                ? Center(
                                    child: Text(
                                      'No products in this section yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: AppColors.outline),
                                    ),
                                  )
                                : _showAllProductsGrid
                                    ? GridView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                          AppSpacing.space3,
                                          AppSpacing.space3,
                                          AppSpacing.space3,
                                          AppSpacing.space2,
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: AppSpacing.space3,
                                          crossAxisSpacing: AppSpacing.space3,
                                          childAspectRatio: 0.56,
                                        ),
                                        itemCount: allGroups.length,
                                        itemBuilder: (context, index) {
                                          final group = allGroups[index];
                                          return _PipeProductCard(
                                            group: group,
                                            gridMode: true,
                                            onTap: () =>
                                                _openProductGroup(group),
                                          );
                                        },
                                      )
                                    : ListView(
                                        padding: const EdgeInsets.fromLTRB(
                                          AppSpacing.space3,
                                          AppSpacing.space3,
                                          AppSpacing.space3,
                                          AppSpacing.space2,
                                        ),
                                        children: [
                                          _PipeProductCard(
                                            group: unifiedGroup!,
                                            onTap: () =>
                                                _openUnifiedSection(unifiedGroup),
                                          ),
                                        ],
                                      ),
                      ),
                    ),
                  ],
                ),
                if (_openFilter != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _openFilter = null),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          PipesFilterChrome(
            activeTab: _openFilter,
            onTabSelected: (tab) => setState(() => _openFilter = tab),
            onClose: () => setState(() => _openFilter = null),
            sort: _sort,
            selectedSize: _size,
            selectedBrand: _selectedBrand,
            onSortChanged: (value) => setState(() => _sort = value),
            onSizeChanged: (value) => setState(() => _size = value),
            onBrandChanged: (value) => setState(() => _selectedBrand = value),
          ),
        ],
      ),
    );
  }
}

class _PlumbingHeader extends StatelessWidget {
  const _PlumbingHeader({
    required this.onBack,
    required this.onSearch,
  });

  final VoidCallback onBack;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5D6),
            AppColors.surface,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space3,
            AppSpacing.space2,
            AppSpacing.space3,
            AppSpacing.space4,
          ),
          child: Row(
            children: [
              _HeaderIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  'Plumbing Pipes\n& Fittings',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              _HeaderIconButton(
                icon: Icons.search_rounded,
                onPressed: onSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.mdAll,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _ModuleSidebar extends StatelessWidget {
  const _ModuleSidebar({
    required this.sections,
    required this.selected,
    required this.onSelected,
  });

  final List<_PipeModuleSectionMeta> sections;
  final _PipeModuleSection selected;
  final ValueChanged<_PipeModuleSection> onSelected;

  static const _accentGreen = Color(0xFF90D151);
  static const _sidebarGrey = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: _sidebarGrey,
      child: SizedBox(
        width: 84,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space5),
          itemBuilder: (context, index) {
            final item = sections[index];
            final isSelected = item.section == selected;

            return InkWell(
              onTap: () => onSelected(item.section),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _accentGreen : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(AppSpacing.space1),
                      child: CategoryImage(
                        imageAsset: item.imageAsset,
                        fallbackIcon: 'plumbing',
                        fallbackIconColor: AppColors.outline,
                        fallbackBackground: AppColors.surface,
                        fit: BoxFit.contain,
                        width: 56,
                        height: 44,
                        iconSize: 22,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.onBackground
                            : AppColors.onSurfaceVariant,
                        height: 1.1,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PipeProductCard extends StatelessWidget {
  const _PipeProductCard({
    required this.group,
    required this.onTap,
    this.gridMode = false,
  });

  final _PipeProductGroup group;
  final VoidCallback onTap;
  final bool gridMode;

  static const _accentGreen = Color(0xFF90D151);
  static const _accentGreenLight = Color(0xFFD8EEBF);
  static const _accentGreenDark = Color(0xFF5FAF2E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = group.representative;
    final price = variant?.sellingPrice ?? variant?.price;
    final unit = variant?.unit ?? 'piece';
    final discountLabel = group.discountLabel;

    final card = InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.02,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CategoryImage(
                            imageAsset: group.imageAsset,
                            imageUrl: group.imageUrl,
                            fallbackIcon: 'plumbing',
                            fallbackIconColor: AppColors.outline,
                            fallbackBackground: AppColors.surfaceContainer,
                            fit: BoxFit.contain,
                            borderRadius: AppRadius.mdAll,
                            iconSize: AppSpacing.space8,
                          ),
                        ),
                      ),
                      Positioned(
                        right: AppSpacing.space2,
                        bottom: AppSpacing.space2,
                        child: Material(
                          color: _accentGreenLight,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.space2,
                                vertical: AppSpacing.space1,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ADD',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: _accentGreenDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${group.variants.length} Products',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _accentGreenDark,
                                      fontSize: 10,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.space1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (price != null)
                        RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onBackground,
                            ),
                            children: [
                              const TextSpan(
                                text: '₹',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: price.toStringAsFixed(0)),
                              TextSpan(
                                text: ' /$unit',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        discountLabel,
                        maxLines: 1,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );

    if (gridMode) return card;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth * 0.54,
          child: card,
        );
      },
    );
  }
}

