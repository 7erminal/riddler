import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

class ApiFetcher {
  ApiFetcher._();

  static final ApiFetcher _instance = ApiFetcher._();
  static ApiFetcher get instance => _instance;

  Future<dynamic> register({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      var response = await ApiServices.register(
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      debugPrint("Func add receipt::: ");
      debugPrint("$response");
      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        debugPrint("About to refresh receipts");
        systemBloc.updateToken(response['result']);
        await userDetails(token: response['result']);
      }

      return response;
    } catch (e) {
      debugPrint("An error occurred in the api fetcher: $e");
      return null;
    }
  }

  Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    try {
      var response = await ApiServices.login(
        username: username,
        password: password,
      );

      debugPrint("Func login::: ");
      debugPrint("$response");
      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        debugPrint("Login successful, updating user data");
        systemBloc.updateToken(response['result']);
        await userDetails(token: response['result']);
      }

      return response;
    } catch (e) {
      debugPrint("An error occurred in the api fetcher: $e");
      return null;
    }
  }

  Future<dynamic> userDetails({
    required String token,
  }) async {
    try {
      var response = await ApiServices.userDetails(
        token: token,
      );

      debugPrint("Func user details::: ");
      debugPrint("$response");
      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        debugPrint("User details successful, updating user data");
        systemBloc.updateUser(response['result']);
      }

      return response;
    } catch (e) {
      debugPrint("An error occurred in the api fetcher: $e");
      return null;
    }
  }

  //
  // Future<dynamic> getCurrencies() async {
  //   try {
  //     var response = await ApiServices.getCurrencies();
  //
  //     debugPrint("Func get currencies::: ");
  //     debugPrint("$response");
  //     if(response["statusCode"] == 200){
  //       debugPrint("About to go update currencies");
  //       systemBloc.updateCurrencies(response["result"]);
  //     }
  //
  //     return response;
  //   } catch(e){
  //     debugPrint("An error occurred in the api fetcher: $e");
  //     return null;
  //   }
  // }

  Future<dynamic> postCurrency({
    required String currencyName,
    required String currencyCode,
    required String currencySymbol,
  }) async {
    try {
      var response = await ApiServices.addCurrency(
        currencyName: currencyName,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
      );

      debugPrint("Func add currency::: ");
      debugPrint("$response");
      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        debugPrint("About to refresh currencies");
        // await getCurrencies();
      }

      return response;
    } catch (e) {
      debugPrint("An error occurred in the api fetcher: $e");
      return null;
    }
  }
}
