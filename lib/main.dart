import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/state/cart_controller.dart';
import 'core/state/quotation_controller.dart';
import 'core/state/recently_viewed_controller.dart';
import 'core/state/reward_controller.dart';
import 'core/state/session_controller.dart';
import 'core/state/wishlist_controller.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ShivaniConstructionsApp());
}

class ShivaniConstructionsApp extends StatelessWidget {
  const ShivaniConstructionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionController()),
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
        title: 'Shivani Constructions',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
