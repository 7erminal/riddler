import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';
import 'package:ridlers/interface/widgets/groupWalletWidgets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0; // 0 = Individual, 1 = Group
  String? _activeGroupId;

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
              // ---- Header ----
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR WALLETS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.inkFaint,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedTab == 0
                              ? bloc.activeWallet.name
                              : _activeGroupWallet(bloc)?.name ?? 'Group wallets',
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
                    child: Icon(
                      _selectedTab == 0 ? Icons.savings_rounded : Icons.group_rounded,
                      color: AppTheme.ink,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ---- Tab switcher ----
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppTheme.primary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.outline, width: 2.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.savings_rounded, size: 18, color: AppTheme.ink),
                            SizedBox(width: 6),
                            Text('Individual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppTheme.primary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.outline, width: 2.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_rounded, size: 18, color: AppTheme.ink),
                            SizedBox(width: 6),
                            Text('Group', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_selectedTab == 0)
                ..._buildIndividualTab(context, bloc)
              else
                ..._buildGroupTab(context, bloc),
            ],
          ),
        ),
      ),
    );
  }

  GroupWallet? _activeGroupWallet(WalletBloc bloc) {
    if (_activeGroupId != null) {
      return bloc.groupWalletById(_activeGroupId!);
    }
    if (bloc.groupWallets.isNotEmpty) {
      return bloc.groupWallets.first;
    }
    return null;
  }

  List<Widget> _buildIndividualTab(BuildContext context, WalletBloc bloc) {
    final wallet = bloc.activeWallet;
    if (bloc.wallets.isEmpty) {
      return [
        Sticker(
          color: AppTheme.lavender,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Icon(Icons.savings_rounded, color: AppTheme.ink, size: 40),
              const SizedBox(height: 12),
              const Text(
                'No wallets yet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create a wallet to start pulling money in from your cards.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 16),
              StickerButton(
                onTap: () => showAddWalletSheet(context),
                color: AppTheme.primary,
                radius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: const Text('Create wallet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      // ---- Wallet switcher ----
      WalletSelector(
        active: wallet,
        wallets: bloc.wallets,
        onSelected: (id) => bloc.setActiveWallet(id),
        onAdd: () => showAddWalletSheet(context),
      ),
      const SizedBox(height: 20),

      // ---- Total + allocation ----
      Sticker(
        color: themeColor(wallet.color),
        radius: 28,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total in wallet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 4),
            Text(Money.formatBig(wallet.totalBalance), style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 16),
            AllocationBar(wallet: wallet),
            const SizedBox(height: 8),
            Row(children: _allocationLegend(wallet)),
          ],
        ),
      ),
      const SizedBox(height: 22),

      // ---- Actions ----
      Row(
        children: [
          Expanded(
            child: StickerButton(
              onTap: () => showTransferSheet(context),
              color: AppTheme.mint,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Column(
                children: [
                  Icon(Icons.south_west_rounded, color: AppTheme.ink, size: 26),
                  SizedBox(height: 6),
                  Text('Pull in', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StickerButton(
              onTap: () => showAddSubWalletSheet(context),
              color: AppTheme.lavender,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Column(
                children: [
                  Icon(Icons.add_box_rounded, color: AppTheme.ink, size: 26),
                  SizedBox(height: 6),
                  Text('New pocket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // ---- Pockets ----
      _pocketHeader(context, wallet),
      const SizedBox(height: 12),
      MainWalletTile(
        amount: wallet.mainBalance,
        onWithdraw: wallet.mainBalance > 0
            ? () => _withdraw(context, wallet.id, null, 'Main Wallet', wallet.mainBalance)
            : null,
      ),
      const SizedBox(height: 12),
      if (wallet.subWallets.isEmpty)
        Sticker(
          color: AppTheme.sky,
          padding: const EdgeInsets.all(22),
          child: const Column(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppTheme.ink, size: 32),
              SizedBox(height: 8),
              Text(
                'Everything stays in the Main wallet for now.\nCreate a pocket to split deposits automatically!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
              ),
            ],
          ),
        )
      else
        for (final w in wallet.subWallets)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SubWalletTile(
              subWallet: w,
              onTap: () => showEditSubWalletSheet(context, w),
              onDelete: () => _deleteSubWallet(context, wallet.id, w),
              onWithdraw: w.balance > 0
                  ? () => _withdraw(context, wallet.id, w.id, w.title, w.balance)
                  : null,
            ),
          ),

      const SizedBox(height: 12),
      Row(children: [Text('Activity', style: Theme.of(context).textTheme.titleLarge)]),
      const SizedBox(height: 12),
      if (bloc.transactionsFor(wallet.id).isEmpty)
        const _EmptyActivity()
      else
        for (final tx in bloc.transactionsFor(wallet.id).take(20))
          _ActivityTile(tx: tx),
    ];
  }

  List<Widget> _buildGroupTab(BuildContext context, WalletBloc bloc) {
    final gw = _activeGroupWallet(bloc);
    if (gw == null) {
      return [
        Sticker(
          color: AppTheme.lavender,
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Icon(Icons.group_rounded, color: AppTheme.ink, size: 40),
              const SizedBox(height: 12),
              const Text(
                'No group wallets yet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create a group wallet to save together with friends and family.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 16),
              StickerButton(
                onTap: () => showAddWalletSheet(context),
                color: AppTheme.primary,
                radius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: const Text('Create group wallet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink)),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      // ---- Group wallet selector ----
      GroupWalletSelector(
        active: gw,
        wallets: bloc.groupWallets,
        onSelected: (id) => setState(() => _activeGroupId = id),
        onAdd: () => showAddWalletSheet(context),
      ),
      const SizedBox(height: 20),

      // ---- Total balance ----
      Sticker(
        color: themeColor(gw.color),
        radius: 28,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Total in group wallet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.inkSoft)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.outline, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group_rounded, size: 14, color: AppTheme.ink),
                      const SizedBox(width: 4),
                      Text('${gw.acceptedMembers.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(Money.formatBig(gw.totalBalance), style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 16),
            AllocationBar(wallet: _gwAsWallet(gw)),
            const SizedBox(height: 8),
            Row(children: _allocationLegend(_gwAsWallet(gw))),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // ---- Pockets ----
      Row(
        children: [
          Text('Pockets', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          Text(
            gw.splitMode == 'figures' ? 'Priority split' : '${Money.percent(gw.allocatedPercent)} allocated',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.inkSoft),
          ),
        ],
      ),
      const SizedBox(height: 12),
      MainWalletTile(amount: gw.mainBalance),
      const SizedBox(height: 12),
      if (gw.subWallets.isEmpty)
        Sticker(
          color: AppTheme.sky,
          padding: const EdgeInsets.all(22),
          child: const Column(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppTheme.ink, size: 32),
              SizedBox(height: 8),
              Text(
                'No pockets yet.\nCreate one to split deposits automatically!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
              ),
            ],
          ),
        )
      else
        for (final w in gw.subWallets)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SubWalletTile(subWallet: w),
          ),
      const SizedBox(height: 24),

      // ---- Members ----
      Row(
        children: [
          Text('Members', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (gw.ownerId == systemBloc.phone)
            GestureDetector(
              onTap: () => _addMember(context, gw),
              child: const Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, size: 20, color: AppTheme.primaryDark),
                  SizedBox(width: 4),
                  Text(
                    'Add member',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          Text('${gw.acceptedMembers.length} of ${gw.memberCount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.inkSoft)),
        ],
      ),
      const SizedBox(height: 12),
      for (final m in gw.members)
        GroupMemberTile(
          member: m,
          isOwner: gw.ownerId == systemBloc.phone,
          onRemove: (gw.ownerId == systemBloc.phone && !m.isOwner)
              ? () => _removeMember(context, gw.id, m)
              : null,
        ),

      const SizedBox(height: 12),
      Row(children: [Text('Activity', style: Theme.of(context).textTheme.titleLarge)]),
      const SizedBox(height: 12),
      if (bloc.transactionsFor(gw.id).isEmpty)
        const _EmptyActivity()
      else
        for (final tx in bloc.transactionsFor(gw.id).take(20))
          _ActivityTile(tx: tx),
    ];
  }

  Widget _pocketHeader(BuildContext context, Wallet wallet) {
    return Row(
      children: [
        Text('Pockets', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        GestureDetector(
          onTap: () => _deleteWallet(context),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.delete_outline_rounded, color: AppTheme.inkFaint, size: 22),
          ),
        ),
        Text(
          wallet.splitMode == 'figures' ? 'Priority split' : '${Money.percent(wallet.allocatedPercent)} allocated',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.inkSoft),
        ),
      ],
    );
  }

  Future<void> _withdraw(BuildContext context, String walletId, String? subWalletId, String title, double available) {
    return showWithdrawSheet(context, walletId: walletId, subWalletId: subWalletId, title: title, available: available);
  }

  Future<void> _deleteSubWallet(BuildContext context, String walletId, SubWallet w) async {
    final ok = await confirmDelete(context, title: 'Remove ${w.title}?', message: 'Its percentage goes back to the main wallet. Its balance stays.', confirmLabel: 'Remove pocket');
    if (!ok || !context.mounted) return;
    await walletService.deleteSubWallet(walletId: walletId, subWalletId: w.id);
  }

  Future<void> _deleteWallet(BuildContext context) async {
    final bloc = context.read<WalletBloc>();
    final wallet = bloc.activeWallet;
    final refund = wallet.totalBalance > 0
        ? '\n\nMoney still inside (${Money.format(wallet.totalBalance)}) will be sent back to the cards it came from.'
        : '';
    final ok = await confirmDelete(context, title: 'Delete ${wallet.name}?', message: 'The wallet and its pockets are removed.$refund', confirmLabel: 'Delete wallet');
    if (!ok || !context.mounted) return;
    await walletService.deleteWallet(wallet.id);
  }

  Future<void> _addMember(BuildContext context, GroupWallet gw) async {
    await showAddGroupMemberSheet(context, groupWalletId: gw.id);
  }

  Future<void> _removeMember(BuildContext context, String walletId, GroupMember member) async {
    final ok = await confirmDelete(context, title: 'Remove ${member.name.isNotEmpty ? member.name : member.phone}?', message: 'They will lose access to this group wallet.', confirmLabel: 'Remove member');
    if (!ok || !context.mounted) return;
    await groupWalletService.removeMember(walletId, member.id);
  }

  /// Lifts a group wallet into a plain [Wallet] so the allocation bar and
  /// legend can reuse the individual-wallet rendering.
  Wallet _gwAsWallet(GroupWallet gw) => Wallet(
    id: gw.id,
    name: gw.name,
    color: gw.color,
    subWallets: gw.subWallets,
    totalBalance: gw.totalBalance,
    splitMode: gw.splitMode,
    createdAt: gw.createdAt,
  );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.outline, width: 1.5),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
          ),
        ),
      ],
    );
  }
}

/// Legend row describing how a wallet splits its deposits. In figures mode
/// pockets are listed in priority order with their target amount.
List<Widget> _allocationLegend(Wallet wallet) {
  if (wallet.splitMode == 'figures') {
    final targets = [...wallet.subWallets]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return [
      const Expanded(child: _LegendDot(color: AppTheme.primaryDark, label: 'Main')),
      for (final w in targets)
        Expanded(
          child: _LegendDot(
            color: themeColor(w.color),
            label: '${w.title} ${Money.formatCompact(w.allocation ?? 0)}',
          ),
        ),
    ];
  }
  return [
    Expanded(child: _LegendDot(color: AppTheme.primaryDark, label: 'Main ${Money.percent(wallet.remainingPercent)}')),
    for (final w in wallet.subWallets)
      Expanded(child: _LegendDot(color: themeColor(w.color), label: '${w.title} ${Money.percent(w.percentage)}')),
  ];
}

class _ActivityTile extends StatelessWidget {
  final WalletTransaction tx;

  const _ActivityTile({required this.tx});

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
              color: tx.isDeposit ? AppTheme.mint : AppTheme.pink,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.outline, width: 2.5),
            ),
            child: Icon(
              tx.isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: AppTheme.ink,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.isDeposit
                      ? 'From ${tx.cardName ?? 'a card'}'
                      : _withdrawLabel(tx),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateLabel(tx.createdAt),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkFaint),
                ),
              ],
            ),
          ),
          Text(
            '${tx.isDeposit ? '+' : '-'} ${Money.format(tx.amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: tx.isDeposit ? AppTheme.success : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  String _withdrawLabel(WalletTransaction tx) {
    if (tx.destinationType == 'card') {
      return 'To ${tx.destinationName ?? 'a card'}';
    }
    if (tx.destinationType == 'momo') {
      final num = tx.destinationNumber;
      final tail = num != null && num.length > 4 ? num.substring(num.length - 4) : '';
      return 'To ${tx.destinationName ?? 'mobile money'}${tail.isNotEmpty ? ' • $tail' : ''}';
    }
    return 'Withdrawal';
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: AppTheme.surface,
      padding: const EdgeInsets.all(22),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_rounded, color: AppTheme.inkFaint, size: 34),
          SizedBox(height: 8),
          Text(
            'No activity yet.\nPull money in to get things going!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}
