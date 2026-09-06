import 'package:customerapp/core/state/catalog_controller.dart';
import 'package:customerapp/core/state/cart_controller.dart';
import 'package:customerapp/core/state/quotation_controller.dart';
import 'package:customerapp/core/state/recently_viewed_controller.dart';
import 'package:customerapp/core/state/reward_controller.dart';
import 'package:customerapp/core/state/session_controller.dart';
import 'package:customerapp/core/state/wishlist_controller.dart';
import 'package:customerapp/core/theme/app_theme.dart';
import 'package:customerapp/features/catalog/data/mock/catalog_mock_data.dart';
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
        home: child,
      ),
    );
  }

  testWidgets('Pipe configurator shows default pricing and add to cart on load',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        const UpvcPipeVariantListScreen(
          subCategoryId: CatalogMockData.upvcPipesSubCategoryId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Selling Price (SP)'), findsOneWidget);
    expect(find.text('Add to cart'), findsOneWidget);
    expect(
      find.text('Select brand and size to view pricing.'),
      findsNothing,
    );
  });

  testWidgets('Changing brand updates pricing in any order', (tester) async {
    await tester.pumpWidget(
      wrap(
        const UpvcPipeVariantListScreen(
          subCategoryId: CatalogMockData.upvcPipesSubCategoryId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final brandDropdown = find.byType(DropdownButton<String>).first;
    await tester.ensureVisible(brandDropdown);
    await tester.tap(brandDropdown, warnIfMissed: false);
    await tester.pumpAndSettle();

    final supreme = CatalogMockData.brandById('brand-supreme')!.name;
    await tester.tap(find.text(supreme).last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Selling Price (SP)'), findsOneWidget);
    expect(find.text('Add to cart'), findsOneWidget);
  });

  testWidgets('Changing type updates product title', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        const UpvcPipeVariantListScreen(
          subCategoryId: CatalogMockData.upvcPipesSubCategoryId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('SCH40'), findsWidgets);

    final typeDropdown = find.byType(DropdownButton<String>).at(1);
    await tester.scrollUntilVisible(
      typeDropdown,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(typeDropdown);
    await tester.pumpAndSettle();

    await tester.tap(find.text('SCH80').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('SCH80'), findsWidgets);
    expect(find.textContaining('SCH40'), findsNothing);
  });
}
