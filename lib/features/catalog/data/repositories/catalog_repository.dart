import '../../../../core/network/api_client.dart';
import '../models/api_catalog_product.dart';
import '../mappers/catalog_api_mapper.dart';

class CatalogRepository {
  CatalogRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Fetches active pipe catalog items from the dashboard FastAPI backend.
  Future<List<ApiCatalogProduct>> fetchPipeCatalog() async {
    final envelope = await _apiClient.getJson(
      '/catalog',
      queryParameters: {
        'category': CatalogApiMapper.pipesCategoryName,
        'active_only': 'true',
      },
    );
    final data = envelope['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ApiCatalogProduct.fromJson)
        .toList();
  }

  void dispose() => _apiClient.dispose();
}
