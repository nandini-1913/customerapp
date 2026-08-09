import '../domain/models/auth_models.dart';

/// Abstraction for authentication operations.
/// Swap [MockAuthService] with a real API/Firebase implementation later.
abstract class AuthService {
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResult> signInWithGoogle();

  Future<AuthResult> continueAsGuest();

  Future<AuthResult> register(RegisterRequest request);

  Future<AuthResult> sendOtp({
    required String mobileNumber,
  });

  Future<AuthResult> verifyOtp({
    required String mobileNumber,
    required String otp,
  });

  Future<AuthResult> sendPasswordResetCode({
    required String identifier,
    required bool isEmail,
  });

  Future<AuthResult> resetPassword({
    required String identifier,
    required String newPassword,
  });
}
