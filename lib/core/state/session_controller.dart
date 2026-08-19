import 'package:flutter/foundation.dart';

import '../../features/auth/domain/models/auth_models.dart';
import '../../features/catalog/domain/models/catalog_models.dart';

/// Holds the currently logged-in / demo user.
class SessionController extends ChangeNotifier {
  AppUserProfile _user = AppUserProfile.demo;

  AppUserProfile get user => _user;

  void setUser(AppUserProfile user) {
    _user = user;
    notifyListeners();
  }

  void setFromAuth(AuthUser authUser) {
    final name = (authUser.fullName != null && authUser.fullName!.trim().isNotEmpty)
        ? authUser.fullName!.trim()
        : (authUser.isGuest
            ? 'Guest'
            : (authUser.email.isNotEmpty
                ? authUser.email.split('@').first
                : AppUserProfile.demo.name));
    _user = AppUserProfile(
      id: authUser.id,
      name: name,
      email: authUser.email.isEmpty ? null : authUser.email,
      phone: authUser.mobileNumber,
      businessName: authUser.businessName,
      isGuest: authUser.isGuest,
    );
    notifyListeners();
  }

  void resetToDemo() {
    _user = AppUserProfile.demo;
    notifyListeners();
  }
}
