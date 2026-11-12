// import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

SystemBloc systemBloc = SystemBloc();
WalletBloc walletBloc = WalletBloc();
WalletService walletService = WalletService(walletBloc);
GroupWalletService groupWalletService = GroupWalletService(walletBloc);
CardShareService cardShareService = CardShareService(walletBloc);
AuthService authService = AuthService();

/// Named routes used across the app.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
}
