import 'package:ridlers/index.dart';

/// Local phone number + PIN authentication.
///
/// The account lives only on the device: one phone number, a 4-digit PIN,
/// and an optional display name. Everything is persisted via [StorageService].
class AuthService {
  /// Creates the user's account (first time use).
  ///
  /// Returns a failure message when the phone is already registered,
  /// otherwise `null` on success.
  Future<String?> createAccount({
    required String phone,
    required String pin,
    String? name,
  }) async {
    final existing = await StorageService.getUser();
    if (existing != null && existing['phone'] == phone) {
      return 'That phone number already has an account.';
    }
    if (pin.length < 4) {
      return 'Pick a PIN of at least 4 digits.';
    }

    await StorageService.saveUser({
      'phone': phone,
      'pin': pin,
      'name': name?.trim().isEmpty == true ? null : name?.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await StorageService.setLoggedIn(true);
    systemBloc.updateUserPhone(phone, name?.trim().isEmpty == true ? null : name?.trim());
    return null;
  }

  /// Signs the user back in with phone + PIN.
  Future<String?> login({
    required String phone,
    required String pin,
  }) async {
    final user = await StorageService.getUser();
    if (user == null) return 'No account found for that number.';
    if (user['phone'] != phone) return 'No account found for that number.';
    if (user['pin'] != pin) return 'Wrong PIN. Try again.';

    await StorageService.setLoggedIn(true);
    systemBloc.updateUserPhone(phone, user['name']?.toString());
    return null;
  }

  Future<bool> isLoggedIn() => StorageService.isLoggedIn();

  /// Checks a PIN against the stored one (used to authorise service actions).
  Future<bool> verifyPin(String pin) async {
    final user = await StorageService.getUser();
    return user != null && user['pin'] == pin;
  }

  Future<String?> currentPhone() async {
    final user = await StorageService.getUser();
    return user?['phone']?.toString();
  }

  Future<void> logout() async {
    await StorageService.clearUser();
    systemBloc.clearData();
  }
}
