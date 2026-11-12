import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const String id = AppRoutes.home;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    WalletScreen(),
    CardsScreen(),
    SettingsScreen(),
  ];

  void switchTab(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _CartoonNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _CartoonNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _CartoonNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.home_rounded, label: 'Home'),
      (icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
      (icon: Icons.credit_card_rounded, label: 'Cards'),
      (icon: Icons.tune_rounded, label: 'Settings'),
    ];

    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppTheme.outline, width: AppTheme.borderWidth),
          boxShadow: [
            BoxShadow(
              color: AppTheme.stickerShadowColor,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Semantics(
                  label: items[i].label,
                  button: true,
                  selected: index == i,
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: index == i ? AppTheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: index == i
                            ? Border.all(color: AppTheme.outline, width: 2)
                            : null,
                      ),
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: index == i ? 1.08 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                items[i].icon,
                                color: index == i ? AppTheme.ink : AppTheme.inkSoft,
                                size: 25,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              items[i].label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: index == i ? AppTheme.ink : AppTheme.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
