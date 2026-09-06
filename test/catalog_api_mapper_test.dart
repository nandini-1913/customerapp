import 'package:customerapp/features/catalog/data/mappers/catalog_api_mapper.dart';
import 'package:customerapp/features/catalog/data/models/api_catalog_product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps API catalog item to pipe variant with stock and pricing', () {
    const item = ApiCatalogProduct(
      id: 'cat-1',
      name: 'PIPE SDR-11',
      category: 'Pipes & Tubing',
      unit: 'pcs',
      standardRate: 294,
      productCode: 'M511130301',
      productName: 'PIPE SDR-11',
      type: 'CPVC',
      productGroup: 'PIPE SDR-11',
      brand: 'Astral',
      mrp: 294,
      sellingPrice: 294,
      stock: 5,
      imageUrl: 'https://example.com/pipe.jpg',
      isActive: true,
    );

    final variant = CatalogApiMapper.toVariants([item]).single;
    expect(variant.subCategoryName, 'CPVC');
    expect(variant.brandName, 'Astral');
    expect(variant.inStock, isTrue);
    expect(variant.imageUrl, 'https://example.com/pipe.jpg');
    expect(variant.pipeType, 'PIPE SDR-11');
  });

  test('inactive API items are excluded', () {
    const item = ApiCatalogProduct(
      id: 'cat-2',
      name: 'Hidden',
      category: 'Pipes & Tubing',
      unit: 'pcs',
      standardRate: 10,
      isActive: false,
    );

    expect(CatalogApiMapper.toVariants([item]), isEmpty);
  });
}
