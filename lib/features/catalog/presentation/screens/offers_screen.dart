import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_elevation.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock/catalog_mock_data.dart';
import '../../domain/models/catalog_models.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = CatalogMockData.offers;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Current Offers'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space4),
        itemCount: offers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Material(
            color: AppColors.surface,
            elevation: AppElevation.level1,
            shadowColor: AppColors.shadow,
            borderRadius: AppRadius.lgAll,
            child: InkWell(
              borderRadius: AppRadius.lgAll,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.offerDetail,
                  arguments: OfferDetailArgs(offerId: offer.id),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space2,
                        vertical: AppSpacing.space1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        offer.discountText,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(offer.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.space1),
                    Text(offer.description, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.space2),
                    Text(offer.validUntil, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OfferDetailScreen extends StatelessWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    Offer? offer;
    for (final o in CatalogMockData.offers) {
      if (o.id == offerId) {
        offer = o;
        break;
      }
    }
    if (offer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offer')),
        body: const Center(child: Text('Offer not found')),
      );
    }

    final resolved = offer;
    final products = resolved.productIds
        .map(CatalogMockData.productById)
        .whereType<CatalogProduct>()
        .toList();
    final categoryId = resolved.categoryId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(resolved.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          Text(
            resolved.discountText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(resolved.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.space2),
          if (resolved.minimumOrder.isNotEmpty)
            Text(resolved.minimumOrder, style: Theme.of(context).textTheme.bodyMedium),
          Text(resolved.validUntil, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.space5),
          Text('Eligible products', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.space3),
          ...products.map(
            (p) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(p.name),
              subtitle: Text(
                '${CatalogMockData.variantsByProduct(p.id).length} brands · ${p.priceWithUnit}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.productDetail,
                  arguments: ProductDetailArgs(productId: p.id),
                );
              },
            ),
          ),
          if (categoryId != null) ...[
            const SizedBox(height: AppSpacing.space4),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.categoryBrowse,
                  arguments: CategoryBrowseArgs(categoryId: categoryId),
                );
              },
              child: const Text('Browse category'),
            ),
          ],
        ],
      ),
    );
  }
}
