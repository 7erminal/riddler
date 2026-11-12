import 'package:ridlers/index.dart';
import 'package:flutter/material.dart';

/// Backend API endpoints for group wallets.
///
/// All methods are stubbed — they return [ServerFailure] placeholders so the
/// app compiles and runs while the backend is being built. When the backend
/// is ready, replace the placeholder return values with actual [ApisCaller]
/// calls.
class GroupWalletApi {
  GroupWalletApi._();

  static Future<Map<String, dynamic>?> createGroupWallet({
    required String name,
    required String color,
    required List<Map<String, dynamic>> members,
  }) async {
    debugPrint('GroupWalletApi.createGroupWallet → stub (backend not connected)');
    // TODO: Replace with actual API call when backend is ready.
    // final body = {'name': name, 'color': color, 'members': members};
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.groupWallets}',
    //   body: body,
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null; // placeholder — backend not connected
  }

  static Future<List<dynamic>?> getGroupWallets() async {
    debugPrint('GroupWalletApi.getGroupWallets → stub');
    // TODO:
    // final resp = await ApisCaller.instance.getData(
    //   path: '${ApiPaths.groupWallets}',
    //   builder: (data) => data as List<dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> getGroupWallet(String id) async {
    debugPrint('GroupWalletApi.getGroupWallet → stub');
    // TODO:
    // final resp = await ApisCaller.instance.getData(
    //   path: '${ApiPaths.groupWallet}/$id/',
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> inviteMember({
    required String walletId,
    required String phone,
  }) async {
    debugPrint('GroupWalletApi.inviteMember → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.groupWallet}/$walletId/invite/',
    //   body: {'phone': phone},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<void> removeMember({
    required String walletId,
    required String memberId,
  }) async {
    debugPrint('GroupWalletApi.removeMember → stub');
    // TODO:
    // await ApisCaller.instance.deleteData(
    //   path: '${ApiPaths.groupWallet}/$walletId/members/$memberId/',
    //   builder: (data) => data,
    // );
  }

  static Future<Map<String, dynamic>?> acceptInvite({
    required String walletId,
    required String phone,
  }) async {
    debugPrint('GroupWalletApi.acceptInvite → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.groupWallet}/$walletId/accept/',
    //   body: {'phone': phone},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<Map<String, dynamic>?> rejectInvite({
    required String walletId,
    required String phone,
  }) async {
    debugPrint('GroupWalletApi.rejectInvite → stub');
    // TODO:
    // final resp = await ApisCaller.instance.postData(
    //   path: '${ApiPaths.groupWallet}/$walletId/reject/',
    //   body: {'phone': phone},
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp;
    return null;
  }

  static Future<bool> verifyPhone(String phone) async {
    debugPrint('GroupWalletApi.verifyPhone → stub');
    // TODO:
    // final resp = await ApisCaller.instance.getData(
    //   path: '${ApiPaths.verifyPhone}$phone/',
    //   builder: (data) => data as Map<String, dynamic>,
    // );
    // return resp != null;
    return true; // placeholder — assume valid
  }
}
