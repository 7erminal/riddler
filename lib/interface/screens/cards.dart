import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await walletService.load();
            await cardShareService.load();
          },
          color: AppTheme.primaryDark,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BANK CARDS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.inkFaint,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your cards',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Sticker(
                    color: AppTheme.sky,
                    radius: 18,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.credit_card_rounded, color: AppTheme.ink, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Sticker(
                color: AppTheme.sky,
                radius: 26,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total across cards',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Money.format(bloc.totalCardBalance),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    StickerButton(
                      onTap: () => showAddCardSheet(context),
                      color: AppTheme.primary,
                      radius: 18,
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.add_rounded, color: AppTheme.ink, size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              if (bloc.cards.isEmpty && bloc.sharedCardsWithMe.isEmpty)
                _EmptyCards()
              else ...[
                for (final card in bloc.cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: BankCardView(
                      card: card,
                      onTap: () => _openCard(context, card),
                    ),
                  ),
                if (bloc.sharedCardsWithMe.isNotEmpty) ...[
                  Row(
                    children: [
                      Text('Shared with you', style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      const Icon(Icons.group_rounded, color: AppTheme.inkFaint, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cards other customers shared with you. Withdrawals need their approval.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                  ),
                  const SizedBox(height: 12),
                  for (final card in bloc.sharedCardsWithMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BankCardView(
                        card: card,
                        isShared: true,
                        onTap: () => _openCard(context, card),
                      ),
                    ),
                ],
              ],

              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Mobile money', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  StickerButton(
                    onTap: () => showAddMoMoSheet(context),
                    color: AppTheme.sky,
                    radius: 16,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.add_rounded, color: AppTheme.ink, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Numbers you can withdraw into from your pockets.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 12),
              if (bloc.momoWallets.isEmpty)
                Sticker(
                  color: AppTheme.lavender,
                  radius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_iphone_rounded, color: AppTheme.ink, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No mobile money wallets yet.\nAdd one to receive withdrawals.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
                        ),
                      ),
                      StickerButton(
                        onTap: () => showAddMoMoSheet(context),
                        color: AppTheme.primary,
                        radius: 16,
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.add_rounded, color: AppTheme.ink, size: 22),
                      ),
                    ],
                  ),
                )
              else
                for (final momo in bloc.momoWallets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MoMoTile(
                      momo: momo,
                      onTap: () => _momoActions(context, momo),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _momoActions(BuildContext context, MoMoWallet momo) async {
    final ok = await confirmDelete(
      context,
      title: 'Remove ${momo.name}?',
      message: '${momo.provider} • ${momo.number} will no longer be available for withdrawals.',
      confirmLabel: 'Remove',
    );
    if (!ok || !context.mounted) return;
    await walletService.deleteMoMo(momo.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${momo.name} removed')),
      );
    }
  }

  Future<void> _openCard(BuildContext context, BankCard card) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CardDetailScreen(card: card)),
    );
  }
}

class _EmptyCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: AppTheme.pink,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(Icons.credit_card_off_rounded, color: AppTheme.ink, size: 44),
          const SizedBox(height: 12),
          const Text(
            'No cards attached yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
          const SizedBox(height: 6),
          const Text(
            'Attach your bank cards to check balances and pull money into your wallet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
          ),
          const SizedBox(height: 18),
          StickerButton(
            onTap: () => showAddCardSheet(context),
            color: AppTheme.primary,
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: const Text(
              'Attach a card',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoMoTile extends StatelessWidget {
  final MoMoWallet momo;
  final VoidCallback onTap;

  const _MoMoTile({required this.momo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: themeColor(momo.color),
      radius: 20,
      dy: 3,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.outline, width: 2.5),
            ),
            child: const Icon(Icons.phone_iphone_rounded, color: AppTheme.ink, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  momo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  '${momo.provider} • ${momo.number}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.inkFaint),
        ],
      ),
    );
  }
}
