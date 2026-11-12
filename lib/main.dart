import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => systemBloc),
        ChangeNotifierProvider(create: (_) => walletBloc),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ridlers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: SplashRouter.id,
      routes: {
        SplashRouter.id: (_) => const SplashRouter(),
        LoginScreen.id: (_) => const LoginScreen(),
      },
    );
  }
}
