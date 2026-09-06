import '../../domain/models/catalog_models.dart';
import '../mock/catalog_mock_data.dart';
import '../models/api_catalog_product.dart';

/// Maps dashboard backend catalog JSON into existing Flutter UI models.
abstract final class CatalogApiMapper {
  static const String pipesCategoryName = 'Pipes & Tubing';

  static List<ProductVariant> toVariants(List<ApiCatalogProduct> items) {
    return items
        .where(
          (item) =>
              item.isActive &&
              item.id.isNotEmpty &&
              item.category.trim() == pipesCategoryName,
        )
        .map(_toVariant)
        .toList();
  }

  static ProductVariant _toVariant(ApiCatalogProduct item) {
    final typeName = item.type ?? '';
    final subCategoryId = _subCategoryIdForType(typeName);
    final brandName = item.brand ?? 'Unknown';
    final brandId = item.brandId ?? _brandIdFromName(brandName);
    final mrp = item.mrp ?? item.standardRate;
    final selling = item.sellingPrice ?? item.standardRate;
    final discountPercent = item.discount;
    final discountRate = discountPercent == null
        ? (mrp > 0 ? ((mrp - selling) / mrp).clamp(0.0, 1.0) : null)
        : (discountPercent / 100).clamp(0.0, 1.0);
    final stockQty = item.stock;
    final stockStatus = stockQty == null
        ? StockStatus.inStock
        : stockQty > 0
            ? StockStatus.inStock
            : StockStatus.outOfStock;
    final sizeLabel = _sizeLabel(item);
    final productGroup = item.productGroup?.trim();
    final displayName = item.productName?.trim().isNotEmpty == true
        ? item.productName!.trim()
        : item.name.trim();
    final pipeTypeLabel = _firstNonEmpty([
      productGroup,
      typeName,
      displayName,
    ]);

    return ProductVariant(
      id: item.id,
      productId: item.productCode ?? item.id,
      productName: displayName,
      sku: item.productCode ?? item.id,
      brandId: brandId,
      brandName: brandName,
      categoryId: CatalogMockData.pipesTubingCategoryId,
      categoryName: pipesCategoryName,
      subCategoryId: subCategoryId,
      subCategoryName: typeName.isNotEmpty ? typeName : 'Pipes',
      description: productGroup ?? displayName,
      price: selling,
      unit: item.unit,
      icon: 'plumbing',
      rating: 4.5,
      reviewCount: 0,
      stockStatus: stockStatus,
      specifications: {
        if (item.productCode != null) 'SKU': item.productCode!,
        if (sizeLabel.isNotEmpty) 'Size': sizeLabel,
        if (item.length != null) 'Length': item.length!,
        if (productGroup != null) 'Product Group': productGroup,
        'Type': typeName,
      },
      imageAsset: '',
      imageUrl: _validImageUrl(item.imageUrl),
      specSummary: productGroup ?? typeName,
      pipeType: pipeTypeLabel,
      mrp: mrp,
      discountRate: discountRate,
    );
  }

  static String _subCategoryIdForType(String typeName) {
    final slug = typeName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) return CatalogMockData.pipesTubingCategoryId;
    return 'cat-pipes-tubing__$slug';
  }

  static String _brandIdFromName(String brandName) {
    final slug = brandName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'brand-$slug';
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static String _sizeLabel(ApiCatalogProduct item) {
    if (item.sizeMm != null && item.sizeMm! > 0) {
      final mm = item.sizeMm!;
      final asInt = mm == mm.roundToDouble();
      return asInt ? '${mm.toInt()}mm' : '${mm}mm';
    }
    if (item.sizeInch != null && item.sizeInch!.trim().isNotEmpty) {
      return item.sizeInch!.trim();
    }
    if (item.productCode != null && item.productCode!.trim().isNotEmpty) {
      return item.productCode!.trim();
    }
    return item.name.trim();
  }

  static String? _validImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return null;
    }
    return trimmed;
  }
}
