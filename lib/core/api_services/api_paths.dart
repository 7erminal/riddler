class ApiPaths{
  static const baseUrl = "https://api.ridlers.com";

  // API
  static const apiBaseUrl = "$baseUrl/core/api";

  // User
  // Register API endpoint
  static const register = "$baseUrl/core/register/";
  static const login = "$baseUrl/core/login/";

  static const user = "$baseUrl/core/me/";

  // Currencies
  // Currencies API endpoint
  static const currencies = "$apiBaseUrl/currencies/";

  // Configs
  static const configs = "$apiBaseUrl/configs/";

  // FX rates
  static const fx = "$apiBaseUrl/fx/";

  // Units
  static const units = "$apiBaseUrl/units/";

  // Receipts
  static const receipts = "$apiBaseUrl/receipts/";
  static String records({String? receiptId}) =>
      "$apiBaseUrl/receipts/${receiptId ?? ""}/records/";
}
