import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

abstract class Exceptions {
  static String errorMessage(dynamic e, {String? server}) {
    if (e is TimeoutException) {
      return 'Looks like the server is taking to long to respond.';
    }

    if (e is DioException) {
      if (e.error is SocketException) {
        return e.error.toString().replaceAll("SocketException: ", "");
      }

      final statusCode = e.response?.statusCode;

      switch (statusCode) {
        case 400:
          return 'Looks like you have an unstable network at the moment';
        case 403:
          return 'Forbidden';
        case 404:
          return 'Request page not found';
        default:
          return 'Cannot connect to server${server ?? e.toString().substring(0, e.toString().length < 30 ? e.toString().length : 30)}';
      }
    } else {
      return e.toString().substring(0, e.toString().length < 30 ? e.toString().length : 30);
    }
  }
}
