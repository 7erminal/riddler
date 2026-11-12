import 'package:ridlers/index.dart';
import 'package:flutter/material.dart';

class ApiServices {

  static Future<dynamic> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      var body = {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      };
      dynamic resp = await ApisCaller.instance.postData(
        path: ApiPaths.register,
        body: body,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("REGISTER RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    try {
      var body = {
        'phoneNumber': username,
        'password': password,
      };
      dynamic resp = await ApisCaller.instance.postData(
        path: ApiPaths.login,
        body: body,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("LOGIN RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> userDetails({
    required String token,
  }) async {
    try {
      var header = {
        'Authorization': 'Token $token',
      };
      dynamic resp = await ApisCaller.instance.getData(
        path: ApiPaths.user,
        headers: header,
        // body: body,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("LOGIN RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> getCurrencies() async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
          path: ApiPaths.currencies,
          builder: (data) {
            debugPrint("Data $data");
            return data;
          },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> getConfigs({
    required String code
}) async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
          path: '${ApiPaths.configs}$code/',
          builder: (data) {
            debugPrint("Data $data");
            return data;
          },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> getFX() async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
        path: ApiPaths.fx,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> getUnits() async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
        path: ApiPaths.units,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> receipts() async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
        path: ApiPaths.receipts,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> addCurrency({
    required String currencyCode,
    required String currencyName,
    required String currencySymbol,
  }) async {
    try {
      var body = {
        'currencyCode': currencyCode,
        'currencyName': currencyName,
        'currencySymbol': currencySymbol,
      };
      debugPrint("BODY::: $body");
      dynamic resp = await ApisCaller.instance.postData(
        path: ApiPaths.currencies,
        body: body,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> addUnit({
    required String unitName,
    required String unitCode,
    required String unitSymbol,
    required String unitType,
    String unitDescription = '',
  }) async {
    try {
      dynamic resp = await ApisCaller.instance.postData(
        path: ApiPaths.units,
        body: {
          'unitName': unitName,
          'unitCode': unitCode,
          'unitSymbol': unitSymbol,
          'unitType': unitType,
          'unitDescription': unitDescription,
          'active': '1',
        },
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> addFx({
    required String sendCurrency,
    required String receiveCurrency,
    required String exchangeRate,
  }) async {
    try {
      dynamic resp = await ApisCaller.instance.postData(
        path: ApiPaths.fx,
        body: {
          'sendCurrency': sendCurrency,
          'receiveCurrency': receiveCurrency,
          'exchangeRate': exchangeRate,
          'active': '1',
        },
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> addConfiguration({
    required String processConfigId,
    required String businessName,
    required String businessAddress,
    required String businessEmail,
    required String businessPhone,
    required String processCode,
    required String defaultCurrency,
    required String shippingMode,
    required String weightUnit,
    required String customRate,
    required String customRateUnit,
    required String shippingMargin,
    required String shippingMarginUnit,
    required String handlingFee,
    required String handlingFeeUnit,
    required String sellerShipperDeliveryFee,
    required String sellerShipperDeliveryFeeUnit,
  }) async {
    try {
      dynamic resp = await ApisCaller.instance.putData(
        path: '${ApiPaths.configs}$processConfigId/',
        body: {
          'businessName': businessName,
          'businessAddress': businessAddress,
          'businessEmail': businessEmail,
          'businessPhone': businessPhone,
          'processCode': processCode,
          'defaultCurrency': defaultCurrency,
          'shippingMode': shippingMode,
          'weightUnit': weightUnit,
          'customRate': customRate,
          'customRateUnit': customRateUnit,
          'shippingMargin': shippingMargin,
          'shippingMarginUnit': shippingMarginUnit,
          'handlingFee': handlingFee,
          'handlingFeeUnit': handlingFeeUnit,
          'sellerShipperDeliveryFee': sellerShipperDeliveryFee,
          'sellerShipperDeliveryFeeUnit': sellerShipperDeliveryFeeUnit,
          'active': '1',
        },
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch (e) {
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> getReceipts() async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
        path: ApiPaths.receipts,
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }

  static Future<dynamic> getRecords({
    required String receiptId
}) async {
    // await initLocalStorage();
    // var token = localStorage.getItem('token') ?? '0';

    try {
      dynamic resp = await ApisCaller.instance.getData(
        path: ApiPaths.records(receiptId: receiptId),
        builder: (data) {
          debugPrint("Data $data");
          return data;
        },
      );
      debugPrint("RESPONSE::: $resp");
      return resp;
    } catch(e){
      debugPrint("An error occurred $e");
      return false;
    }
  }
}