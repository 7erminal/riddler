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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outline, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD9CFB6),
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: index == i ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: index == i ? 1.1 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          items[i].icon,
                          color: AppTheme.ink,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
