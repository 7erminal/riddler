import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart'
;
class Functions{
  Functions._();

  // create a constructor for the class
  static final Functions _instance = Functions._();

  static Functions get instance => _instance;

  String getCountry(String countryCode){
    String country = countryCode;
    if(countryCode=="GH"){
      country = "Ghana";
    }

    return country;
  }

  /// Generates a compact unique id.
  static String generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecondsSinceEpoch & 0xFFFFF)}';

  /// Rounds money to 2 decimal places, avoiding floating point drift.
  static double round2(double value) => (value * 100).roundToDouble() / 100;

  String trimCountryCode(String countryCode){
    String countryCodePrefix = countryCode;
    countryCodePrefix = countryCode.substring(1);

    return countryCodePrefix;
  }

  /*
  * ###########################################
  * ##### convert the image to base64 #########
  * ###########################################
  * */
  static dynamic convertImageToBase64(File image) async {
    debugPrint("Converting image to base64");
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    return base64Image;
  }
}