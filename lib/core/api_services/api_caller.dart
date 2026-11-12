import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ridlers/index.dart';

class ApisCaller {
  ApisCaller._() {
    dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 60), // 60 seconds
        receiveTimeout: const Duration(seconds: 60), // 60 seconds
      ),
    );
  }

  static final instance = ApisCaller._();

  late Dio dio;

  // get data from api
  Future<T> getData<T>({
    required String path,
    Map<String, String>? queryParameters,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? headers
  }) async {
    try {
      debugPrint("api path: $path ... ");
      debugPrint("parameters are $queryParameters");
      Response response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return builder(response.data);
    } catch (e) {
      debugPrint(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      final failure = ServerFailure(message: errorMessage);
      return builder(failure);
    }
  }

  // post data to api
  Future<T> postData<T>({
    required String path,
    dynamic queryParameters,
    Map<String, dynamic>? body,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? headers
  }) async {
    try {
      debugPrint("api path: $path ... ");
      // debugPrint("User token is ${userActor.userModel.token}");
      debugPrint("Params are $body or $queryParameters");
      // debugPrint();
      Response response = await dio.post(
        // options: Options(headers: {
        //   HttpHeaders.contentTypeHeader: "application/json",
        // }),
        path,
        // data: queryParameters,
        data: queryParameters ?? body,
        options: Options(headers: headers),
      );
      return builder(response.data);
    } catch (e) {
      debugPrint("Error RECEIVED");
      debugPrint(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      final failure = ServerFailure(message: errorMessage);
      return builder(failure);
    }
  }

  // put data to api
  Future<T> putData<T>({
    required String path,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? headers
  }) async {
    try {
      debugPrint("api path: $path ... ");

      debugPrint("Params are $body or $queryParameters");
      Response response = await dio.put(
        path,
        queryParameters: queryParameters,
        data: body,
        // options: Options(headers: {
        //   // 'Authorization': "Bearer ${userActor.userModel.token}"
        // }),
        options: Options(headers: headers),
      );
      return builder(response.data);
    } catch (e) {
      // debugPrint(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      final failure = ServerFailure(message: errorMessage);
      return builder(failure);
    }
  }

  // patch data to api
  Future<T> patchData<T>({
    required String path,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? headers
  }) async {
    try {
      debugPrint("api path: $path ... ");
      Response response = await dio.patch(
        path,
        queryParameters: queryParameters,
        data: body,
        options: Options(headers: headers),
      );
      return builder(response.data);
    } catch (e) {
      // debugPrint(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      final failure = ServerFailure(message: errorMessage);
      return builder(failure);
    }
  }

  // delete data from api
  Future<T> deleteData<T>({
    required String path,
    Map<String, String>? queryParameters,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? headers
  }) async {
    try {
      debugPrint("api path: $path ... ");
      Response response = await dio.delete(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return builder(response.data);
    } catch (e) {
      // debugPrint(e.toString());
      final errorMessage = Exceptions.errorMessage(e);
      final failure = ServerFailure(message: errorMessage);
      return builder(failure);
    }
  }
}