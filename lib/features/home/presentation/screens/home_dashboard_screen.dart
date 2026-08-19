import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/recently_viewed_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../catalog/data/mock/catalog_mock_data.dart';
import '../../../catalog/domain/models/catalog_models.dart';
import '../widgets/construction_tools_section.dart';
import '../widgets/current_offers_section.dart';
import '../widgets/featured_banner_carousel.dart';
import '../widgets/featured_products_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_category_card.dart';
import '../widgets/home_greeting.dart';
import '../widgets/home_rewards_card.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/popular_brands_section.dart';
import '../widgets/popular_products_section.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recently_viewed_section.dart';
import '../../domain/models/home_models.dart' as legacy;

/// Home tab content for [MainShell].
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentlyViewedController>().seedIfEmpty(
            CatalogMockData.featuredVariants.take(4).toList(),
          );
    });
  }

  void _open(String route, {Object? arguments}) {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  void _openProduct(CatalogProduct product) {
    _open(
      AppRoutes.productDetail,
      arguments: ProductDetailArgs(productId: product.id),
    );
  }

  void _openVariant(ProductVariant variant) {
    _open(
      AppRoutes.productDetail,
      arguments: ProductDetailArgs(
        productId: variant.productId,
        variantId: variant.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    final recentlyViewed = context.watch<RecentlyViewedController>().items;

    final quickActions = CatalogMockData.quickActions
        .map(
          (a) => legacy.QuickAction(
            id: a.id,
            title: a.title,
            icon: a.icon,
            routeName: a.routeName,
            iconColor: a.iconColor,
            iconBackground: a.iconBackground,
          ),
        )
        .toList();

    final categories = CatalogMockData.categories
        .map(
          (c) => legacy.HomeCategory(
            id: c.id,
            name: c.name,
            itemCount: c.itemCount,
            icon: c.icon,
            iconColor: c.iconColor,
            iconBackground: c.iconBackground,
            imageAsset: c.imageAsset,
          ),
        )
        .toList();

    final banners = CatalogMockData.banners
        .map(
          (b) => legacy.HomeBanner(
            id: b.id,
            eyebrow: b.eyebrow,
            headline: b.headline,
            description: b.description,
            ctaLabel: b.ctaLabel,
            routeName: b.routeName.isNotEmpty
                ? b.routeName
                : AppRoutes.categoryBrowse,
            icon: b.icon,
            gradientStart: b.gradientStart,
            gradientEnd: b.gradientEnd,
          ),
        )
        .toList();

    final brands = CatalogMockData.brands
        .map(
          (b) => legacy.HomeBrand(
            id: b.id,
            name: b.name,
            productCount: b.productCount,
            abbreviation: b.abbreviation,
            color: b.color,
            logoAsset: b.logoAsset,
          ),
        )
        .toList();

    final offers = CatalogMockData.offers
        .map(
          (o) => legacy.HomeOffer(
            id: o.id,
            discountLabel: o.discountText,
            title: o.title,
            subtitle: o.minimumOrder.isNotEmpty ? o.minimumOrder : o.description,
            endsOn: o.validUntil,
            ctaLabel: 'Explore',
            routeName: AppRoutes.offerDetail,
          ),
        )
        .toList();

    final tools = CatalogMockData.tools
        .map(
          (t) => legacy.ConstructionTool(
            id: t.id,
            title: t.title,
            subtitle: t.subtitle,
            icon: t.icon,
            routeName: t.routeName,
          ),
        )
        .toList();

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeAppBar(
            user: user,
            onRewards: () => _open(AppRoutes.myRewards),
            onNotifications: () => _open(AppRoutes.notifications),
            onProfile: () => _open(AppRoutes.profile),
            onCart: () => _open(AppRoutes.cart),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space3,
                      AppSpacing.space4,
                      0,
                    ),
                    child: HomeSearchBar(
                      onTap: () => _open(AppRoutes.search),
                      onVoice: () => _open(AppRoutes.search),
                      onScan: () => _open(AppRoutes.search),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      AppSpacing.space5,
                      AppSpacing.space4,
                      AppSpacing.space4,
                    ),
                    child: HomeGreeting(user: user),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.space4,
                      0,
                      AppSpacing.space4,
                      AppSpacing.space4,
                    ),
                    child: const HomeRewardsCard(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: FeaturedBannerCarousel(
                      banners: banners,
                      onCta: (banner) {
                        final source = CatalogMockData.banners
                            .where((b) => b.id == banner.id)
                            .toList();
                        final match = source.isEmpty ? null : source.first;
                        if (match?.categoryId != null) {
                          _open(
                            AppRoutes.categoryBrowse,
                            arguments: CategoryBrowseArgs(
                              categoryId: match!.categoryId!,
                            ),
                          );
                        } else if (match?.routeName == AppRoutes.offers) {
                          _open(AppRoutes.offers);
                        } else {
                          _open(banner.routeName);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: QuickActionsRow(
                      actions: quickActions,
                      onTap: (action) => _open(action.routeName),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: CategoriesSection(
                      categories: categories,
                      onViewAll: () => _open(AppRoutes.categories),
                      onCategoryTap: (category) {
                        _open(
                          AppRoutes.categoryBrowse,
                          arguments:
                              CategoryBrowseArgs(categoryId: category.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  FeaturedProductsSection(
                    products: CatalogMockData.featuredProducts,
                    onViewAll: () => _open(
                      AppRoutes.productList,
                      arguments: const ProductListArgs(title: 'Featured Products'),
                    ),
                    onProductTap: _openProduct,
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  PopularBrandsSection(
                    brands: brands,
                    onViewAll: () => _open(AppRoutes.brands),
                    onBrandTap: (brand) {
                      _open(
                        AppRoutes.brandProducts,
                        arguments: BrandProductsArgs(brandId: brand.id),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: PopularProductsSection(
                      products: CatalogMockData.popularProducts,
                      onViewAll: () => _open(
                        AppRoutes.productList,
                        arguments:
                            const ProductListArgs(title: 'Popular Products'),
                      ),
                      onProductTap: _openProduct,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  RecentlyViewedSection(
                    products: recentlyViewed,
                    onViewAll: () => _open(
                      AppRoutes.productList,
                      arguments:
                          const ProductListArgs(title: 'Popular Products'),
                    ),
                    onTap: _openVariant,
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  CurrentOffersSection(
                    offers: offers,
                    onViewAll: () => _open(AppRoutes.offers),
                    onExplore: (offer) {
                      _open(
                        AppRoutes.offerDetail,
                        arguments: OfferDetailArgs(offerId: offer.id),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  const _SectionDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space4,
                    ),
                    child: ConstructionToolsSection(
                      tools: tools,
                      onViewAll: () => _open(AppRoutes.materialCalculator),
                      onToolTap: (tool) => _open(tool.routeName),
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.space16 + AppSpacing.space12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space4,
        0,
        AppSpacing.space4,
        AppSpacing.space5,
      ),
      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
    );
  }
}
