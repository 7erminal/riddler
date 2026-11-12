import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridlers/index.dart';

/// Thin persistence layer over [SharedPreferences].
///
/// Everything the Ridlers app stores locally lives here: the phone + PIN
/// user account, attached bank cards, the wallet and its transactions.
class StorageService {
  StorageService._();

  static const _userKey = 'ridlers_user';
  static const _cardsKey = 'ridlers_cards';
  static const _walletKey = 'ridlers_wallet';
  static const _walletsKey = 'ridlers_wallets';
  static const _momoKey = 'ridlers_momo';
  static const _txKey = 'ridlers_transactions';
  static const _activityKey = 'ridlers_activity';
  static const _requestsKey = 'ridlers_requests';
  static const _splitsKey = 'ridlers_splits';
  static const _groupWalletsKey = 'ridlers_group_wallets';
  static const _cardSharesKey = 'ridlers_card_shares';
  static const _withdrawalRequestsKey = 'ridlers_withdrawal_requests';
  static const _walletDepositsKey = 'ridlers_wallet_deposits';
  static const _loggedInKey = 'ridlers_logged_in';

  // ---- User ----
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_loggedInKey);
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  // ---- Cards ----
  static Future<void> saveCards(List<BankCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cardsKey,
      jsonEncode(cards.map((c) => c.toJson()).toList()),
    );
  }

  static Future<List<BankCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BankCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Wallets ----
  static Future<void> saveWallets(List<Wallet> wallets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _walletsKey,
      jsonEncode(wallets.map((w) => w.toJson()).toList()),
    );
  }

  static Future<List<Wallet>> loadWallets() async {
    final prefs = await SharedPreferences.getInstance();

    // New multi-wallet storage.
    final raw = prefs.getString(_walletsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Wallet.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Legacy single-wallet storage: migrate it over.
    final legacy = prefs.getString(_walletKey);
    if (legacy != null) {
      final wallet = Wallet.fromJson(jsonDecode(legacy) as Map<String, dynamic>);
      await saveWallets([wallet]);
      await prefs.remove(_walletKey);
      return [wallet];
    }

    return [];
  }

  // ---- Wallet deposits ----
  static Future<void> saveWalletDeposits(List<WalletDeposit> deposits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _walletDepositsKey,
      jsonEncode(deposits.map((d) => d.toJson()).toList()),
    );
  }

  static Future<List<WalletDeposit>> loadWalletDeposits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_walletDepositsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WalletDeposit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Mobile money ----
  static Future<void> saveMoMo(List<MoMoWallet> wallets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_momoKey, jsonEncode(wallets.map((w) => w.toJson()).toList()));
  }

  static Future<List<MoMoWallet>> loadMoMo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_momoKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MoMoWallet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Transactions ----
  static Future<void> saveTransactions(List<WalletTransaction> txs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_txKey, jsonEncode(txs.map((t) => t.toJson()).toList()));
  }

  static Future<List<WalletTransaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_txKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Banking activity (transfers, airtime, data, requests) ----
  static Future<void> saveActivity(List<ActivityRecord> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _activityKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<ActivityRecord>> loadActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activityKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ActivityRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Money requests ----
  static Future<void> saveMoneyRequests(List<MoneyRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _requestsKey,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
  }

  static Future<List<MoneyRequest>> loadMoneyRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_requestsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MoneyRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Split payments ----
  static Future<void> saveSplitPayments(List<SplitPayment> splits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _splitsKey,
      jsonEncode(splits.map((s) => s.toJson()).toList()),
    );
  }

  static Future<List<SplitPayment>> loadSplitPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_splitsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SplitPayment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Group wallets ----
  static Future<void> saveGroupWallets(List<GroupWallet> wallets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _groupWalletsKey,
      jsonEncode(wallets.map((w) => w.toJson()).toList()),
    );
  }

  static Future<List<GroupWallet>> loadGroupWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_groupWalletsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => GroupWallet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Card shares ----
  static Future<void> saveCardShares(List<CardShare> shares) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cardSharesKey,
      jsonEncode(shares.map((s) => s.toJson()).toList()),
    );
  }

  static Future<List<CardShare>> loadCardShares() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardSharesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CardShare.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---- Withdrawal requests ----
  static Future<void> saveWithdrawalRequests(List<WithdrawalRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _withdrawalRequestsKey,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
  }

  static Future<List<WithdrawalRequest>> loadWithdrawalRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_withdrawalRequestsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => WithdrawalRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
