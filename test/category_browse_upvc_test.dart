import 'package:customerapp/core/routes/app_routes.dart';
import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/state/catalog_controller.dart';
import 'package:customerapp/core/state/quotation_controller.dart';
import 'package:customerapp/core/state/recently_viewed_controller.dart';
import 'package:customerapp/core/state/reward_controller.dart';
import 'package:customerapp/core/state/session_controller.dart';
import 'package:customerapp/core/state/wishlist_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/catalog/presentation/screens/pipes_tubing_browse_screen.dart';
import 'package:customerapp/features/catalog/presentation/screens/upvc_pipe_variant_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionController()),
        ChangeNotifierProvider(create: (_) => CatalogController()),
        ChangeNotifierProvider(create: (_) => CartController()),
        ChangeNotifierProvider(create: (_) => WishlistController()),
        ChangeNotifierProvider(create: (_) => RecentlyViewedController()),
        ChangeNotifierProvider(create: (_) => QuotationController()),
        ChangeNotifierProvider(
          create: (context) => RewardController(
            quotationController: context.read<QuotationController>(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        routes: {
          AppRoutes.upvcPipeVariants: (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as UpvcPipeVariantsArgs?;
            return UpvcPipeVariantListScreen(
              subCategoryId: args?.subCategoryId,
              productId: args?.productId,
              title: args?.title,
              heroImageAsset: args?.heroImageAsset,
              categoryIds: args?.categoryIds,
            );
          },
        },
        home: child,
      ),
    );
  }

  testWidgets('pipes module opens configurator from product card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    await tester.pumpWidget(wrap(const PipesTubingBrowseScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Plumbing Pipes'), findsNothing);
    expect(find.textContaining('Plumbing Pipes'), findsOneWidget);

    await tester.tap(find.text('ADD').first);
    await tester.pumpAndSettle();

    expect(find.byType(UpvcPipeVariantListScreen), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });
}
