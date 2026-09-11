import 'package:flutter/foundation.dart';

import '../../features/auth/domain/models/auth_models.dart';
import '../../features/catalog/domain/models/catalog_models.dart';
import '../services/session_storage.dart';

/// Holds the currently logged-in / demo user with local persistence.
class SessionController extends ChangeNotifier {
  AppUserProfile _user = AppUserProfile.demo;
  bool _isLoggedIn = false;
  bool _restored = false;

  AppUserProfile get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isRestored => _restored;

  /// Load saved session from device storage (call once on app start).
  Future<void> restore() async {
    final saved = await SessionStorage.load();
    if (saved != null && saved.id.isNotEmpty) {
      _user = saved;
      _isLoggedIn = true;
    }
    _restored = true;
    notifyListeners();
  }

  void setUser(AppUserProfile user) {
    _user = user;
    notifyListeners();
  }

  Future<void> setFromAuth(AuthUser authUser) async {
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
    _isLoggedIn = true;
    await SessionStorage.save(_user);
    notifyListeners();
  }

  Future<void> logout() async {
    await SessionStorage.clear();
    _user = AppUserProfile.demo;
    _isLoggedIn = false;
    notifyListeners();
  }

  void resetToDemo() {
    _user = AppUserProfile.demo;
    notifyListeners();
  }
}
