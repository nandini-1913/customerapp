import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/catalog_models.dart';
import 'brand_seed_data.dart';
import 'plumbing_catalog_rows.dart';

/// Local catalog built from Excel seed rows + brand dataset.
/// Replace with repository/API later; keep query APIs stable.
abstract final class CatalogMockData {
  static final _CatalogIndex _index = _CatalogIndex.build();

  static List<Category> get categories => _index.categories;
  static List<SubCategory> get subCategories => _index.subCategories;
  static List<Brand> get brands => _index.brands;
  static List<CatalogProduct> get products => _index.products;
  static List<ProductVariant> get variants => _index.variants;

  static List<CatalogProduct> get featuredProducts =>
      products.where((p) => p.isFeatured).toList();

  static List<CatalogProduct> get popularProducts =>
      products.where((p) => p.isPopular).toList();

  static List<ProductVariant> get featuredVariants =>
      variants.where((v) => v.isFeatured).toList();

  static List<ProductVariant> get popularVariants =>
      variants.where((v) => v.isPopular).toList();

  static List<CatalogProduct> productsByCategory(String categoryId) =>
      products.where((p) => p.categoryId == categoryId).toList();

  static List<CatalogProduct> productsBySubCategory(String subCategoryId) =>
      products.where((p) => p.subCategoryId == subCategoryId).toList();

  static List<ProductVariant> variantsByProduct(String productId) =>
      variants.where((v) => v.productId == productId).toList();

  static List<ProductVariant> variantsByBrand(String brandId) =>
      variants.where((v) => v.brandId == brandId).toList();

  static List<ProductVariant> variantsByCategory(String categoryId) =>
      variants.where((v) => v.categoryId == categoryId).toList();

  static CatalogProduct? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  static ProductVariant? variantById(String id) {
    for (final v in variants) {
      if (v.id == id) return v;
    }
    return null;
  }

  static Category? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Brand? brandById(String id) {
    for (final b in brands) {
      if (b.id == id) return b;
    }
    return null;
  }

  static SubCategory? subCategoryById(String id) {
    for (final s in subCategories) {
      if (s.id == id) return s;
    }
    return null;
  }

  static List<SubCategory> subCategoriesFor(String categoryId) =>
      subCategories.where((s) => s.categoryId == categoryId).toList();

  static List<Brand> brandsForCategory(String categoryId) =>
      brands.where((b) => b.categoryIds.contains(categoryId)).toList();

  /// Lowest-priced in-stock variant for a base product (display only).
  static ProductVariant? cheapestVariantFor(String productId) {
    final list = variantsByProduct(productId);
    if (list.isEmpty) return null;
    list.sort((a, b) => a.price.compareTo(b.price));
    return list.first;
  }

  static List<CatalogProduct> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q) ||
              p.categoryName.toLowerCase().contains(q) ||
              p.subCategoryName.toLowerCase().contains(q) ||
              variantsByProduct(p.id).any(
                    (v) => v.brandName.toLowerCase().contains(q),
                  ),
        )
        .toList();
  }

  static List<ProductVariant> searchVariants(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return variants
        .where(
          (v) =>
              v.productName.toLowerCase().contains(q) ||
              v.brandName.toLowerCase().contains(q) ||
              v.categoryName.toLowerCase().contains(q) ||
              v.subCategoryName.toLowerCase().contains(q) ||
              v.sku.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<BannerItem> get banners => [
        BannerItem(
          id: 'banner-pipes',
          eyebrow: 'FEATURED COLLECTION',
          headline: 'Premium Pipes Collection',
          description: 'UPVC, CPVC, HDPE & SWR from top brands',
          ctaLabel: 'Explore Now',
          icon: 'plumbing',
          gradientStart: 0xFF0369A1,
          gradientEnd: 0xFF0891B2,
          categoryId: 'cat-pipes-tubing',
          routeName: AppRoutes.categories,
        ),
        BannerItem(
          id: 'banner-sanitary',
          eyebrow: 'FEATURED COLLECTION',
          headline: 'Sanitary & CP Fittings',
          description: 'Closets, basins, faucets & showers',
          ctaLabel: 'Browse Now',
          icon: 'water_drop',
          gradientStart: 0xFF0F766E,
          gradientEnd: 0xFF14B8A6,
          categoryId: 'cat-sanitary-wares',
        ),
        BannerItem(
          id: 'banner-offers',
          eyebrow: 'FEATURED COLLECTION',
          headline: 'Plumbing Project Offers',
          description: 'Save on bulk pipe & fitting orders',
          ctaLabel: 'View Offers',
          icon: 'local_offer',
          gradientStart: 0xFFB45309,
          gradientEnd: 0xFFD97706,
          routeName: AppRoutes.offers,
        ),
      ];

  static List<Offer> get offers => [
        Offer(
          id: 'offer-pipes',
          title: 'Bulk Pipe Discount',
          description: 'Save on UPVC & CPVC pipe project orders.',
          discountText: '12% OFF',
          minimumOrder: 'Min order ₹25,000',
          validUntil: 'Ends 30 Sep 2026',
          categoryId: 'cat-pipes-tubing',
          productIds: productsByCategory('cat-pipes-tubing')
              .take(4)
              .map((p) => p.id)
              .toList(),
        ),
        Offer(
          id: 'offer-sanitary',
          title: 'Sanitaryware Combo',
          description: 'Seasonal discounts on closets & basins.',
          discountText: '10% OFF',
          minimumOrder: 'On selected sanitaryware',
          validUntil: 'Ends 15 Oct 2026',
          categoryId: 'cat-sanitary-wares',
          productIds: productsByCategory('cat-sanitary-wares')
              .take(3)
              .map((p) => p.id)
              .toList(),
        ),
      ];

  static const List<ConstructionTool> tools = [
    ConstructionTool(
      id: 'tool-material',
      title: 'Material Calculator',
      subtitle: 'Estimate costs from your cart materials',
      icon: 'calculate',
      routeName: AppRoutes.materialCalculator,
    ),
    ConstructionTool(
      id: 'tool-converter',
      title: 'Unit Converter',
      subtitle: 'Convert units across standards',
      icon: 'swap_horiz',
      routeName: AppRoutes.unitConverter,
    ),
    ConstructionTool(
      id: 'tool-quantity',
      title: 'Quantity Estimator',
      subtitle: 'Project-based material planning',
      icon: 'architecture',
      routeName: AppRoutes.quantityEstimator,
    ),
  ];

  static List<
          ({
            String id,
            String title,
            String icon,
            String routeName,
            int iconColor,
            int iconBackground
          })> get quickActions =>
      [
        (
          id: 'qa-quotation',
          title: 'Generate\nQuotation',
          icon: 'request_quote',
          routeName: AppRoutes.cart,
          iconColor: AppColors.primary.toARGB32(),
          iconBackground: AppColors.primaryContainer.toARGB32(),
        ),
        (
          id: 'qa-dealer',
          title: 'Find\nDealer',
          icon: 'storefront',
          routeName: AppRoutes.dealers,
          iconColor: AppColors.tertiary.toARGB32(),
          iconBackground: AppColors.tertiaryContainer.toARGB32(),
        ),
        (
          id: 'qa-brands',
          title: 'Top\nBrands',
          icon: 'business',
          routeName: AppRoutes.brands,
          iconColor: AppColors.info.toARGB32(),
          iconBackground: AppColors.infoContainer.toARGB32(),
        ),
        (
          id: 'qa-offers',
          title: 'Current\nOffers',
          icon: 'local_offer',
          routeName: AppRoutes.offers,
          iconColor: AppColors.secondary.toARGB32(),
          iconBackground: AppColors.secondaryContainer.toARGB32(),
        ),
      ];
}

class _CatalogIndex {
  _CatalogIndex({
    required this.categories,
    required this.subCategories,
    required this.brands,
    required this.products,
    required this.variants,
  });

  final List<Category> categories;
  final List<SubCategory> subCategories;
  final List<Brand> brands;
  final List<CatalogProduct> products;
  final List<ProductVariant> variants;

  static _CatalogIndex build() {
    final rows = PlumbingCatalogRows.all;
    final categoryMeta = <String, _CatMeta>{
      'Pipes & Tubing': _CatMeta(
        id: 'cat-pipes-tubing',
        icon: 'plumbing',
        description: 'UPVC, CPVC, HDPE and SWR pipes',
        iconColor: AppColors.primary.toARGB32(),
        iconBackground: AppColors.primaryContainer.toARGB32(),
        unit: 'pcs',
        imageAsset: 'assets/images/categories/pipes_tubing.png',
      ),
      'Fittings': _CatMeta(
        id: 'cat-fittings',
        icon: 'build',
        description: 'Elbows, tees, couplers and transitions',
        iconColor: AppColors.info.toARGB32(),
        iconBackground: AppColors.infoContainer.toARGB32(),
        unit: 'pcs',
        imageAsset: 'assets/images/categories/fittings.png',
      ),
      'Valves & Controls': _CatMeta(
        id: 'cat-valves-controls',
        icon: 'tune',
        description: 'Ball, gate, check, float and butterfly valves',
        iconColor: AppColors.secondary.toARGB32(),
        iconBackground: AppColors.secondaryContainer.toARGB32(),
        unit: 'pcs',
        imageAsset: 'assets/images/categories/valves_controls.png',
      ),
      'Sanitary Wares': _CatMeta(
        id: 'cat-sanitary-wares',
        icon: 'water_drop',
        description: 'Closets, basins, urinals and cisterns',
        iconColor: AppColors.tertiary.toARGB32(),
        iconBackground: AppColors.tertiaryContainer.toARGB32(),
        unit: 'pcs',
        imageAsset: 'assets/images/categories/sanitary_wares.png',
      ),
      'CP Fittings': _CatMeta(
        id: 'cat-cp-fittings',
        icon: 'shower',
        description: 'Faucets, showers and chrome fittings',
        iconColor: 0xFF0F766E,
        iconBackground: 0xFFCCFBF1,
        unit: 'pcs',
        imageAsset: 'assets/images/categories/cp_fittings.png',
      ),
      'Drainage & Accessories': _CatMeta(
        id: 'cat-drainage-accessories',
        icon: 'grid_view',
        description: 'Floor drains, traps and covers',
        iconColor: AppColors.onSurfaceVariant.toARGB32(),
        iconBackground: AppColors.surfaceVariant.toARGB32(),
        unit: 'pcs',
        imageAsset: 'assets/images/categories/drainage_accessories.png',
      ),
      'Consumables': _CatMeta(
        id: 'cat-consumables',
        icon: 'science',
        description: 'Solvent cement, sealing and mounting',
        iconColor: AppColors.warning.toARGB32(),
        iconBackground: AppColors.warningContainer.toARGB32(),
        unit: 'pcs',
        imageAsset: 'assets/images/categories/consumables.png',
      ),
    };

    final categoryOrder = <String>[];
    final subOrder = <String, List<String>>{};
    final productCounts = <String, int>{};
    final subCounts = <String, int>{};

    for (final row in rows) {
      if (!categoryOrder.contains(row.mainCategory)) {
        categoryOrder.add(row.mainCategory);
      }
      subOrder.putIfAbsent(row.mainCategory, () => <String>[]);
      if (!subOrder[row.mainCategory]!.contains(row.subCategory)) {
        subOrder[row.mainCategory]!.add(row.subCategory);
      }
      final meta = categoryMeta[row.mainCategory]!;
      productCounts[meta.id] = (productCounts[meta.id] ?? 0) + 1;
      final subId = _subId(meta.id, row.subCategory);
      subCounts[subId] = (subCounts[subId] ?? 0) + 1;
    }

    final categories = <Category>[];
    final subCategories = <SubCategory>[];
    for (final main in categoryOrder) {
      final meta = categoryMeta[main]!;
      final subIds = subOrder[main]!
          .map((s) => _subId(meta.id, s))
          .toList(growable: false);
      categories.add(
        Category(
          id: meta.id,
          name: main,
          icon: meta.icon,
          itemCount: productCounts[meta.id] ?? 0,
          iconColor: meta.iconColor,
          iconBackground: meta.iconBackground,
          imageAsset: meta.imageAsset,
          description: meta.description,
          subCategoryIds: subIds,
        ),
      );
      for (final subName in subOrder[main]!) {
        final sid = _subId(meta.id, subName);
        subCategories.add(
          SubCategory(
            id: sid,
            categoryId: meta.id,
            name: subName,
            productCount: subCounts[sid] ?? 0,
          ),
        );
      }
    }

    final products = <CatalogProduct>[];
    for (final row in rows) {
      final meta = categoryMeta[row.mainCategory]!;
      final subId = _subId(meta.id, row.subCategory);
      final specs = <String, String>{
        'SKU': row.sku,
        'Material': row.material,
        'Size': row.size,
        if (row.attributes.trim().isNotEmpty) 'Attributes': row.attributes,
      };
      products.add(
        CatalogProduct(
          id: row.productId,
          sku: row.sku,
          name: row.name,
          categoryId: meta.id,
          categoryName: row.mainCategory,
          subCategoryId: subId,
          subCategoryName: row.subCategory,
          description: _descriptionFor(row),
          basePrice: row.priceInr,
          unit: _unitFor(row, meta.unit),
          icon: meta.icon,
          imageAsset: meta.imageAsset,
          specifications: specs,
          specSummary: _specSummary(row),
          isFeatured: row.isFeatured,
          isPopular: row.isPopular,
        ),
      );
    }

    final variants = <ProductVariant>[];
    final brandVariantCounts = <String, int>{};

    for (final product in products) {
      final brandList = BrandSeedData.brandsForCategory(product.categoryId);
      final selected = brandList.isEmpty
          ? BrandSeedData.brands.take(2).toList()
          : brandList.take(4).toList();

      for (var i = 0; i < selected.length; i++) {
        final brand = selected[i];
        final delta = _priceDelta(i, selected.length);
        final price = (product.basePrice * (1 + delta))
            .roundToDouble()
            .clamp(1.0, 999999999.0)
            .toDouble();
        final stock = i == selected.length - 1 && selected.length > 2
            ? StockStatus.limited
            : StockStatus.inStock;
        final rating = 4.0 + ((i % 5) * 0.1);
        final variantId = '${product.id}__${brand.id}';
        variants.add(
          ProductVariant(
            id: variantId,
            productId: product.id,
            productName: product.name,
            sku: '${product.sku}-${brand.abbreviation}',
            brandId: brand.id,
            brandName: brand.name,
            categoryId: product.categoryId,
            categoryName: product.categoryName,
            subCategoryId: product.subCategoryId,
            subCategoryName: product.subCategoryName,
            description: product.description,
            price: price,
            unit: product.unit,
            icon: product.icon,
            imageAsset: product.imageAsset,
            rating: double.parse(rating.toStringAsFixed(1)),
            reviewCount: 40 + (i * 37) + (product.id.hashCode % 200).abs(),
            stockStatus: stock,
            specifications: {
              ...product.specifications,
              'Brand': brand.name,
            },
            specSummary: product.specSummary,
            minimumOrderQuantity: 1,
            isFeatured: product.isFeatured && i == 0,
            isPopular: product.isPopular && i <= 1,
          ),
        );
        brandVariantCounts[brand.id] =
            (brandVariantCounts[brand.id] ?? 0) + 1;
      }
    }

    final brands = BrandSeedData.brands
        .map(
          (b) => Brand(
            id: b.id,
            name: b.name,
            abbreviation: b.abbreviation,
            color: b.color,
            productCount: brandVariantCounts[b.id] ?? 0,
            logoAsset: b.logoAsset,
            description: b.description,
            categoryIds: b.categoryIds,
          ),
        )
        .where((b) => b.productCount > 0)
        .toList();

    return _CatalogIndex(
      categories: categories,
      subCategories: subCategories,
      brands: brands,
      products: products,
      variants: variants,
    );
  }

  static String _subId(String categoryId, String subName) {
    final slug = subName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return '${categoryId}__$slug';
  }

  static double _priceDelta(int index, int total) {
    // Spread brand prices around Excel base (± ~6%).
    if (total <= 1) return 0;
    final step = 0.04;
    return (index - (total - 1) / 2) * step;
  }

  static String _unitFor(PlumbingCatalogRow row, String fallback) {
    final attrs = row.attributes.toLowerCase();
    if (attrs.contains('6m') || attrs.contains('3m') || attrs.contains('coil')) {
      return 'pcs';
    }
    if (row.mainCategory == 'Consumables') {
      if (row.subCategory == 'Solvent Cement') return 'can';
      if (row.subCategory == 'Sealing') return 'roll';
      if (row.subCategory == 'Hardware') return 'pack';
      if (row.subCategory == 'Tools') return 'pcs';
    }
    return fallback;
  }

  static String _specSummary(PlumbingCatalogRow row) {
    final parts = <String>[
      if (row.size.trim().isNotEmpty) row.size,
      if (row.material.trim().isNotEmpty) row.material,
    ];
    if (row.attributes.trim().isNotEmpty) {
      final first = row.attributes.split(',').first.trim();
      if (first.isNotEmpty) parts.add(first);
    }
    return parts.take(3).join(' · ');
  }

  static String _descriptionFor(PlumbingCatalogRow row) {
    final buffer = StringBuffer(row.name);
    if (row.material.isNotEmpty) {
      buffer.write(' in ${row.material}');
    }
    if (row.size.isNotEmpty) {
      buffer.write(', size ${row.size}');
    }
    if (row.attributes.isNotEmpty) {
      buffer.write('. ${row.attributes}');
    }
    buffer.write('. Choose from available brands before adding to cart.');
    return buffer.toString();
  }
}

class _CatMeta {
  const _CatMeta({
    required this.id,
    required this.icon,
    required this.description,
    required this.iconColor,
    required this.iconBackground,
    required this.unit,
    required this.imageAsset,
  });

  final String id;
  final String icon;
  final String description;
  final int iconColor;
  final int iconBackground;
  final String unit;
  final String imageAsset;
}
