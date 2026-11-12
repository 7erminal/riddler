import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();
    final user = systemBloc.displayName.isEmpty
        ? (systemBloc.phone.isEmpty ? 'friend' : systemBloc.phone)
        : systemBloc.displayName;

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
                          'Ridlers',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.inkFaint,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hi, $user 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  Sticker(
                    color: AppTheme.primary,
                    radius: 18,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.savings_rounded, color: AppTheme.ink, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ---- Money overview ----
              Sticker(
                color: AppTheme.mint,
                radius: 28,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'In all your wallets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Money.formatBig(bloc.walletTotal),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.outline, width: 2.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Across cards',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.inkFaint,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Money.format(bloc.totalCardBalance),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.outline, width: 2.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pockets',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.inkFaint,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${bloc.totalPockets}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ---- Pending group invitations ----
              if (bloc.pendingGroupInvitations.isNotEmpty)
                for (final gw in bloc.pendingGroupInvitations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Sticker(
                      color: AppTheme.lavender,
                      radius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.outline, width: 2.5),
                                ),
                                child: const Icon(Icons.group_rounded, color: AppTheme.ink, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gw.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${gw.acceptedMembers.length + 1} member${gw.acceptedMembers.isEmpty ? '' : 's'} — you\'re invited!',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StickerButton(
                                  onTap: () => _acceptInvite(context, gw.id),
                                  color: AppTheme.mint,
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('Accept', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StickerButton(
                                  onTap: () => _rejectInvite(context, gw.id),
                                  color: AppTheme.surface,
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('Reject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.inkSoft)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

              // ---- Pending shared-card invitations ----
              if (bloc.pendingShareInvitations.isNotEmpty)
                for (final share in bloc.pendingShareInvitations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Sticker(
                      color: AppTheme.lavender,
                      radius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.outline, width: 2.5),
                                ),
                                child: const Icon(Icons.share_rounded, color: AppTheme.ink, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      share.cardName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${share.cardBankName} • •••• ${share.cardLast4} shared by ${share.ownerPhone} — accept to view it?',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StickerButton(
                                  onTap: () => _acceptShare(context, share.id),
                                  color: AppTheme.mint,
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('Accept', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StickerButton(
                                  onTap: () => _rejectShare(context, share.id),
                                  color: AppTheme.surface,
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('Reject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.inkSoft)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

              // ---- Pending withdrawal approvals ----
              if (bloc.pendingWithdrawalApprovals.isNotEmpty)
                for (final req in bloc.pendingWithdrawalApprovals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Sticker(
                      color: AppTheme.coral,
                      radius: 22,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.outline, width: 2.5),
                                ),
                                child: const Icon(Icons.north_east_rounded, color: AppTheme.ink, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Withdrawal approval',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${req.requesterPhone} wants ${Money.format(req.amount)} from ${req.cardName} (•••• ${req.cardLast4}).',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StickerButton(
                                  onTap: () => _approveWithdrawal(context, req.id),
                                  color: AppTheme.mint,
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('Approve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StickerButton(
                                  onTap: () => _rejectWithdrawal(context, req.id),
                                  color: AppTheme.surface,
                                  radius: 14,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: const Text('Reject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.inkSoft)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

              // ---- Cards ----
              _SectionHeader(
                title: 'Your cards',
                action: 'See all',
                onAction: () => _switchTab(context, 2),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: bloc.cards.isEmpty && bloc.sharedCardsWithMe.isEmpty
                    ? _EmptyCard()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: bloc.cards.length + bloc.sharedCardsWithMe.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          final all = [...bloc.cards, ...bloc.sharedCardsWithMe];
                          if (i == all.length) {
                            return _AddCardTile(onTap: () => showAddCardSheet(context));
                          }
                          final card = all[i];
                          return SizedBox(
                            width: 300,
                            child: BankCardView(
                              card: card,
                              compact: true,
                              isShared: card.isShared,
                              showShareIcon: !card.isShared,
                              onShare: () => showShareCardSheet(context, card),
                              onTap: () => _openCard(context, card),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 22),

              // ---- Services link ----
              StickerButton(
                onTap: () => _open(context, const ServicesScreen()),
                color: AppTheme.primary,
                radius: 22,
                dy: 4,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outline, width: 2.5),
                      ),
                      child: const Icon(Icons.widgets_rounded, color: AppTheme.ink, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Services',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Transfer, airtime, data, split bills & requests',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.ink),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ---- Wallet split ----
              _SectionHeader(
                title: 'Wallet split',
                action: 'Manage',
                onAction: () => _switchTab(context, 1),
              ),
              const SizedBox(height: 12),
              WalletSelector(
                active: bloc.activeWallet,
                wallets: bloc.wallets,
                onSelected: (id) => bloc.setActiveWallet(id),
                onAdd: () => showAddWalletSheet(context),
              ),
              const SizedBox(height: 12),
              Sticker(
                color: AppTheme.surface,
                radius: 24,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AllocationBar(wallet: bloc.activeWallet),
                    const SizedBox(height: 16),
                    MainWalletTile(
                      amount: bloc.activeWallet.mainBalance,
                      onWithdraw: bloc.activeWallet.mainBalance > 0
                          ? () => showWithdrawSheet(
                                context,
                                walletId: bloc.activeWalletId,
                                title: 'Main Wallet',
                                available: bloc.activeWallet.mainBalance,
                              )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    for (final w in bloc.activeWallet.subWallets.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SubWalletTile(
                          subWallet: w,
                          onWithdraw: w.balance > 0
                              ? () => showWithdrawSheet(
                                    context,
                                    walletId: bloc.activeWalletId,
                                    subWalletId: w.id,
                                    title: w.title,
                                    available: w.balance,
                                  )
                              : null,
                        ),
                      ),
                    if (bloc.activeWallet.subWallets.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Center(
                          child: TextButton(
                            onPressed: () => _switchTab(context, 1),
                            child: Text('+ ${bloc.activeWallet.subWallets.length - 3} more pockets'),
                          ),
                        ),
                      ),
                    if (bloc.activeWallet.subWallets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No pockets yet. Create one to start splitting money automatically!',
                          style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---- Recent activity ----
              if (bloc.activity.isNotEmpty) ...[
                const _SectionHeader(title: 'Recent activity'),
                const SizedBox(height: 12),
                for (final item in bloc.activity.take(6))
                  _ActivityTile(item: item),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _switchTab(BuildContext context, int index) {
    final shell = context.findAncestorStateOfType<MainShellState>();
    shell?.switchTab(index);
  }

  Future<void> _acceptInvite(BuildContext context, String walletId) async {
    final pin = await showPinPrompt(
      context,
      title: 'Join group wallet',
      subtitle: 'Enter your PIN to confirm.',
      verify: (pin) => authService.verifyPin(pin),
    );
    if (pin == null || !context.mounted) return;
    await groupWalletService.acceptInvite(walletId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You joined the group wallet!')),
    );
  }

  Future<void> _rejectInvite(BuildContext context, String walletId) async {
    final ok = await confirmDelete(
      context,
      title: 'Decline invitation?',
      message: 'You won\'t have access to this group wallet.',
      confirmLabel: 'Decline',
    );
    if (!ok || !context.mounted) return;
    await groupWalletService.rejectInvite(walletId);
  }

  void _openCard(BuildContext context, BankCard card) {
    _open(context, CardDetailScreen(card: card));
  }

  Future<void> _acceptShare(BuildContext context, String shareId) async {
    final pin = await showPinPrompt(
      context,
      title: 'Accept shared card',
      subtitle: 'Enter your PIN to confirm access.',
      verify: (pin) => authService.verifyPin(pin),
    );
    if (pin == null || !context.mounted) return;
    await cardShareService.acceptShare(shareId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can now view and withdraw from the shared card!')),
    );
  }

  Future<void> _rejectShare(BuildContext context, String shareId) async {
    final ok = await confirmDelete(
      context,
      title: 'Decline access?',
      message: 'You won\'t be able to see or use the shared card.',
      confirmLabel: 'Decline',
    );
    if (!ok || !context.mounted) return;
    await cardShareService.rejectShare(shareId);
  }

  Future<void> _approveWithdrawal(BuildContext context, String requestId) async {
    final pin = await showPinPrompt(
      context,
      title: 'Approve withdrawal',
      subtitle: 'Enter your PIN to confirm this transfer.',
      verify: (pin) => authService.verifyPin(pin),
    );
    if (pin == null || !context.mounted) return;
    final ok = await cardShareService.approveWithdrawal(requestId, pin: pin);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal approved and transferred.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't approve — the card may not have enough balance.")),
      );
    }
  }

  Future<void> _rejectWithdrawal(BuildContext context, String requestId) async {
    final ok = await confirmDelete(
      context,
      title: 'Reject withdrawal?',
      message: 'The requesting customer will not receive the money.',
      confirmLabel: 'Reject',
    );
    if (!ok || !context.mounted) return;
    await cardShareService.rejectWithdrawal(requestId);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
                decoration: TextDecoration.underline,
                decorationThickness: 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityRecord item;

  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: AppTheme.surface,
      radius: 18,
      dy: 3,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kindColor(item.kind),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.outline, width: 2.5),
            ),
            child: Icon(_kindIcon(item.kind), color: AppTheme.ink, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
                ),
              ],
            ),
          ),
          Text(
            '${item.isOut ? '-' : '+'} ${Money.format(item.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: item.isOut ? AppTheme.error : AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  IconData _kindIcon(String kind) {
    switch (kind) {
      case 'airtime':
        return Icons.smartphone_rounded;
      case 'data':
        return Icons.wifi_rounded;
      case 'request':
        return Icons.request_page_rounded;
      case 'split':
        return Icons.call_split_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _kindColor(String kind) {
    switch (kind) {
      case 'airtime':
        return AppTheme.pink;
      case 'data':
        return AppTheme.sky;
      case 'request':
        return AppTheme.coral;
      case 'split':
        return AppTheme.periwinkle;
      default:
        return AppTheme.mint;
    }
  }
}

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: () => showAddCardSheet(context),
      color: AppTheme.pink,
      radius: 24,
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_card_rounded, color: AppTheme.ink, size: 40),
          SizedBox(height: 10),
          Text(
            'Attach your first bank card',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCardTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: AppTheme.sky,
      radius: 24,
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_rounded, color: AppTheme.ink, size: 44),
          SizedBox(height: 8),
          Text(
            'Add card',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
          ),
        ],
      ),
    );
  }
}
