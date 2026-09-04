import 'package:customerapp/features/catalog/data/mock/catalog_mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UPVC subcategory id matches constant used by summary card gate', () {
    final subs = CatalogMockData.subCategoriesFor('cat-pipes-tubing');
    final upvc = subs.firstWhere((s) => s.name == 'UPVC');
    expect(upvc.id, CatalogMockData.upvcPipesSubCategoryId);
    expect(CatalogMockData.isUpvcPipesSubCategory(upvc.id), isTrue);
  });

  test('UPVC pipe variants are generated for pipe SKUs only', () {
    final variants = CatalogMockData.upvcPipeVariants;
    expect(variants, isNotEmpty);
    expect(
      variants.every((v) => v.subCategoryId == CatalogMockData.upvcPipesSubCategoryId),
      isTrue,
    );
    expect(
      variants.every((v) => v.pipeType != null),
      isTrue,
    );
  });
}
