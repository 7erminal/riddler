import 'package:flutter/material.dart';

/// Backend API endpoints for shared card access.
///
/// All methods are stubbed — they log and return placeholder values so the
/// app compiles and runs while the backend is being built. When the backend
/// is ready, replace the placeholder returns with actual [ApisCaller] calls.
class CardShareApi {
  CardShareApi._();

  static Future<Map<String, dynamic>?> shareCard({
    required String cardId,
    required String phone,
  }) async {
    debugPrint('CardShareApi.shareCard → stub (backend not connected)');
    // TODO: Replace with actual API call when backend is ready.
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.cardShares}',
    //   body: {'card_id': cardId, 'phone': phone},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<List<dynamic>?> getCardShares() async {
    debugPrint('CardShareApi.getCardShares → stub');
    // TODO:
    // final resp = await ApisCaller.instance.getData(
    //   path: '${ApiPaths.cardShares}',
    //   builder: (data) => data as List<dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> acceptShare(String shareId) async {
    debugPrint('CardShareApi.acceptShare → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.cardShare}/$shareId/accept/',
    //   body: const {},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> rejectShare(String shareId) async {
    debugPrint('CardShareApi.rejectShare → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.cardShare}/$shareId/reject/',
    //   body: const {},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> requestWithdrawal({
    required String cardId,
    required double amount,
  }) async {
    debugPrint('CardShareApi.requestWithdrawal → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.cardShare}/$cardId/withdraw/',
    //   body: {'amount': amount},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> approveWithdrawal(String requestId) async {
    debugPrint('CardShareApi.approveWithdrawal → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.cardShare}/withdraw/$requestId/approve/',
    //   body: const {},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> rejectWithdrawal(String requestId) async {
    debugPrint('CardShareApi.rejectWithdrawal → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.cardShare}/withdraw/$requestId/reject/',
    //   body: const {},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<bool> verifyPhone(String phone) async {
    debugPrint('CardShareApi.verifyPhone → stub');
    return true; // placeholder — assume valid
  }
}