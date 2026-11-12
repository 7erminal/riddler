import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  static const String id = AppRoutes.splash;

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await walletService.load();
    await cardShareService.load();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final loggedIn = await authService.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                            color: AppTheme.outline,
                            width: 4,
                          ),
                          boxShadow: AppTheme.stickerShadow(
                            const Color(0xFFD9CFB6),
                            dy: 8,
                          ),
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          color: AppTheme.ink,
                          size: 54,
                        ),
                      ),
                      Positioned(
                        right: -14,
                        bottom: -14,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.mint,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.outline,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.attach_money_rounded,
                            color: AppTheme.ink,
                            size: 24,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -14,
                        top: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.coral,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.outline,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppTheme.ink,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Ridlers',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pocket money, sorted.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 44),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryDark,
                      ),
                      backgroundColor: AppTheme.divider,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
