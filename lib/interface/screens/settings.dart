import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();
    final name = systemBloc.displayName.isNotEmpty
        ? systemBloc.displayName
        : 'Ridler';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.inkFaint,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 14),

            // ---- Profile ----
            Sticker(
              color: AppTheme.mint,
              radius: 26,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.outline, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        name.isEmpty ? 'R' : name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          systemBloc.phone.isEmpty ? 'Phone login' : systemBloc.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Stats ----
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    color: AppTheme.sky,
                    icon: Icons.credit_card_rounded,
                    label: 'Cards',
                    value: '${bloc.cards.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    color: AppTheme.lavender,
                    icon: Icons.savings_rounded,
                    label: 'Wallets',
                    value: '${bloc.wallets.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    color: AppTheme.coral,
                    icon: Icons.percent_rounded,
                    label: 'Pockets',
                    value: '${bloc.totalPockets}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ---- How it works ----
            Sticker(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded, color: AppTheme.ink, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'How Ridlers works',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _HowRow(
                    n: '1',
                    text: 'Attach your bank cards and check their balances at a glance.',
                  ),
                  _HowRow(
                    n: '2',
                    text: 'Pull money in — it leaves the card and lands in your wallet.',
                  ),
                  _HowRow(
                    n: '3',
                    text: 'Create pockets with a % each. Deposits split automatically.',
                  ),
                  _HowRow(
                    n: '4',
                    text: 'Whatever isn\'t in a pocket stays in the Main wallet.',
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All wallets under a wallet add up to 100%.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.inkFaint),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            StickerButton(
              onTap: () => _logout(context),
              color: AppTheme.pink,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: AppTheme.ink, size: 22),
                  SizedBox(width: 8),
                  Text('Log out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Ridlers v1.0 • Your money stays on your device',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDelete(
      context,
      title: 'Log out of Ridlers?',
      message: 'Your wallet and cards are saved on this device. You can sign back in with your phone and PIN.',
      confirmLabel: 'Log out',
    );
    if (!ok || !context.mounted) return;
    await authService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _StatBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;

  const _StatBox({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: color,
      radius: 20,
      dy: 4,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.ink, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _HowRow extends StatelessWidget {
  final String n;
  final String text;

  const _HowRow({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.outline, width: 2),
            ),
            child: Center(
              child: Text(
                n,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.inkSoft, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
