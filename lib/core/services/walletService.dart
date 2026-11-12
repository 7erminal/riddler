import 'package:ridlers/index.dart';

/// Business logic for cards, wallets, their pockets and transfers.
///
/// All mutations are persisted immediately through [StorageService].
class WalletService {
  WalletService(this.bloc);

  final WalletBloc bloc;

  /// Hydrates the bloc from local storage. Safe to call multiple times.
  Future<void> load() async {
    bloc.setCards(await StorageService.loadCards());
    bloc.setMoMoWallets(await StorageService.loadMoMo());

    var wallets = await StorageService.loadWallets();
    if (wallets.isEmpty) {
      wallets = [_defaultWallet()];
      await StorageService.saveWallets(wallets);
    }
    bloc.setWallets(wallets);

    bloc.setTransactions(await StorageService.loadTransactions());
    bloc.setActivity(await StorageService.loadActivity());
    bloc.setMoneyRequests(await StorageService.loadMoneyRequests());
    bloc.setSplitPayments(await StorageService.loadSplitPayments());
    bloc.setGroupWallets(await StorageService.loadGroupWallets());
    bloc.setWalletDeposits(await StorageService.loadWalletDeposits());
  }

  Wallet _defaultWallet() => Wallet(
    id: Functions.generateId(),
    name: 'My Wallet',
    color: 'mint',
    createdAt: DateTime.now(),
  );

  String _resolveWalletId(String? walletId) =>
      walletId ?? bloc.activeWalletId ?? bloc.wallets.first.id;

  Future<void> _persistWallets(List<Wallet> wallets, {String? activeId}) async {
    bloc.setWallets(wallets, activeId: activeId);
    await StorageService.saveWallets(wallets);
  }

  // ---- Wallets ----

  /// Creates a new, separate main wallet (starts at 100% or, in figures
  /// mode, with no target pockets yet).
  Future<void> addWallet({
    required String name,
    required String color,
    String splitMode = 'percent',
  }) async {
    final wallet = Wallet(
      id: Functions.generateId(),
      name: name.trim().isEmpty ? 'New Wallet' : name.trim(),
      color: color,
      splitMode: splitMode,
      createdAt: DateTime.now(),
    );
    final wallets = [...bloc.wallets, wallet];
    await _persistWallets(wallets, activeId: wallet.id);
  }

  /// Deletes a wallet entirely.
  ///
  /// Whatever money is still left inside it is refunded back to the cards it
  /// was pulled in from (proportionally to each card's deposits), so nothing
  /// is lost. The deposit ledger for the wallet is then cleared. The last
  /// wallet can be deleted too.
  Future<void> deleteWallet(String walletId) async {
    final wallet = bloc.walletById(walletId);
    if (wallet == null) return;

    await _refundWallet(wallet);

    final wallets = bloc.wallets.where((w) => w.id != walletId).toList();
    final activeId = bloc.activeWalletId == walletId
        ? (wallets.isEmpty ? null : wallets.first.id)
        : bloc.activeWalletId;
    await _persistWallets(wallets, activeId: activeId);

    final deposits = bloc.walletDeposits
        .where((d) => d.walletId != walletId)
        .toList();
    await _persistDeposits(deposits);
  }

  Future<void> renameWallet(String walletId, String name) async {
    if (name.trim().isEmpty) return;
    final wallets = bloc.wallets
        .map((w) => w.id == walletId ? w.copyWith(name: name.trim()) : w)
        .toList();
    await _persistWallets(wallets);
  }

  // ---- Cards ----

  /// Attaches a new bank card.
  Future<void> addCard({
    required String bankName,
    required String nickname,
    required String cardNumber,
    required double balance,
    required String color,
  }) async {
    final card = BankCard(
      id: Functions.generateId(),
      bankName: bankName,
      nickname: nickname.isEmpty ? bankName : nickname,
      cardNumber: cardNumber.replaceAll(' ', ''),
      balance: balance,
      color: color,
      isPrimary: bloc.cards.isEmpty,
      createdAt: DateTime.now(),
    );
    final cards = [...bloc.cards, card];
    bloc.setCards(cards);
    await StorageService.saveCards(cards);
  }

  /// Manually refreshes a card's balance as reported by its bank.
  Future<void> updateCardBalance(String cardId, double newBalance) async {
    final cards = bloc.cards
        .map((c) => c.id == cardId ? c.copyWith(balance: newBalance) : c)
        .toList();
    bloc.setCards(cards);
    await StorageService.saveCards(cards);
  }

  Future<void> deleteCard(String cardId) async {
    final cards = bloc.cards.where((c) => c.id != cardId).toList();
    bloc.setCards(cards);
    await StorageService.saveCards(cards);
  }

  // ---- Mobile money ----

  Future<void> addMoMo({
    required String provider,
    required String name,
    required String number,
    required String color,
  }) async {
    final wallet = MoMoWallet(
      id: Functions.generateId(),
      provider: provider,
      name: name.trim().isEmpty ? '$provider ${number.substring(number.length - 4)}' : name.trim(),
      number: number.replaceAll(' ', ''),
      color: color,
      createdAt: DateTime.now(),
    );
    final wallets = [...bloc.momoWallets, wallet];
    bloc.setMoMoWallets(wallets);
    await StorageService.saveMoMo(wallets);
  }

  Future<void> deleteMoMo(String momoId) async {
    final wallets = bloc.momoWallets.where((w) => w.id != momoId).toList();
    bloc.setMoMoWallets(wallets);
    await StorageService.saveMoMo(wallets);
  }

  // ---- Sub-wallets ----

  /// Creates a pocket inside a wallet.
  ///
  /// In percentage modes [percentage] can't exceed the un-allocated share.
  /// In figures mode pass a target [allocation] (an actual amount) and an
  /// optional [priority]; when omitted, the pocket takes the next available
  /// priority so the first-created pocket is highest by default.
  Future<bool> addSubWallet({
    String? walletId,
    required String title,
    required String purpose,
    required double percentage,
    required String color,
    double? allocation,
    int? priority,
  }) {
    final wid = _resolveWalletId(walletId);
    final wallet = bloc.walletById(wid);
    if (wallet == null) return Future.value(false);

    final isFigures = wallet.splitMode == 'figures';
    if (isFigures) {
      if (allocation == null || allocation <= 0) return Future.value(false);
    } else if (percentage <= 0 || wallet.allocatedPercent + percentage > 100) {
      return Future.value(false);
    }

    final nextPriority = (wallet.subWallets.isNotEmpty
        ? wallet.subWallets.map((w) => w.priority).reduce((a, b) => a > b ? a : b)
        : 0) + 1;

    final updated = wallet.copyWith(
      subWallets: [
        ...wallet.subWallets,
        SubWallet(
          id: Functions.generateId(),
          title: title,
          purpose: purpose,
          percentage: isFigures ? 0 : percentage,
          color: color,
          allocation: isFigures ? allocation : null,
          priority: isFigures ? (priority ?? nextPriority) : 1,
          createdAt: DateTime.now(),
        ),
      ],
    );
    return _persistWallet(updated);
  }

  Future<void> updateSubWallet({
    String? walletId,
    required SubWallet updated,
  }) async {
    final wid = _resolveWalletId(walletId);
    final wallet = bloc.walletById(wid);
    if (wallet == null) return;
    final wallets = bloc.wallets.map((w) {
      if (w.id != wid) return w;
      return w.copyWith(
        subWallets: w.subWallets
            .map((sub) => sub.id == updated.id ? updated : sub)
            .toList(),
      );
    }).toList();
    await _persistWallets(wallets);
  }

  Future<void> deleteSubWallet({
    String? walletId,
    required String subWalletId,
  }) async {
    final wid = _resolveWalletId(walletId);
    final wallets = bloc.wallets.map((w) {
      if (w.id != wid) return w;
      return w.copyWith(
        subWallets: w.subWallets.where((s) => s.id != subWalletId).toList(),
      );
    }).toList();
    await _persistWallets(wallets);
  }

  // ---- Transfers ----

  /// Moves [amount] from a bank card into a wallet.
  ///
  /// The card balance drops by [amount]; the wallet total grows by [amount]
  /// and every pocket in that wallet receives its configured percentage.
  /// The rounding remainder stays with the main pocket so the books always
  /// balance.
  Future<bool> transferFromCard({
    String? walletId,
    required String cardId,
    required double amount,
    String note = '',
  }) async {
    if (amount <= 0) return false;
    final wid = _resolveWalletId(walletId);
    final wallet = bloc.walletById(wid);
    if (wallet == null) return false;

    final cards = [...bloc.cards];
    final idx = cards.indexWhere((c) => c.id == cardId);
    if (idx == -1) return false;
    if (cards[idx].balance < amount) return false;

    cards[idx] = cards[idx].copyWith(balance: cards[idx].balance - amount);

    final deposited = _depositIntoWallet(wallet, amount);

    final wallets = bloc.wallets
        .map((w) => w.id == wid ? deposited : w)
        .toList();

    final tx = WalletTransaction(
      id: Functions.generateId(),
      walletId: wid,
      type: 'in',
      amount: amount,
      cardId: cardId,
      cardName: cards[idx].nickname,
      note: note,
      createdAt: DateTime.now(),
    );

    bloc.setCards(cards);
    await StorageService.saveCards(cards);
    await _persistWallets(wallets);

    final txs = [tx, ...bloc.transactions];
    bloc.setTransactions(txs);
    await StorageService.saveTransactions(txs);

    await _recordDeposit(
      walletId: wid,
      cardId: cardId,
      cardName: cards[idx].nickname,
      amount: amount,
    );
    return true;
  }

  /// Withdraws [amount] from a card into the main wallet.
  ///
  /// Used both for regular card withdrawals (owner, PIN-confirmed) and for
  /// owner-approved withdrawals on shared cards.
  Future<bool> withdrawFromCard({
    required String cardId,
    required double amount,
  }) async {
    if (bloc.wallets.isEmpty) return false;
    if (!await _debitCard(cardId, amount)) return false;

    final wallet = _depositIntoWallet(bloc.wallets.first, amount);
    final wallets = bloc.wallets
        .map((w) => w.id == wallet.id ? wallet : w)
        .toList();
    await _persistWallets(wallets);

    final card = bloc.cardById(cardId);
    final cardName = card?.nickname ?? 'Card';

    final tx = WalletTransaction(
      id: Functions.generateId(),
      walletId: wallet.id,
      type: 'in',
      amount: amount,
      cardId: cardId,
      cardName: cardName,
      note: '',
      createdAt: DateTime.now(),
    );
    final txs = [tx, ...bloc.transactions];
    bloc.setTransactions(txs);
    await StorageService.saveTransactions(txs);

    await _recordDeposit(
      walletId: wallet.id,
      cardId: cardId,
      cardName: cardName,
      amount: amount,
    );

    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'withdraw',
      title: 'Withdrew to wallet',
      subtitle: cardName,
      amount: amount,
      type: 'in',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Withdraws [amount] out of a pocket.
  ///
  /// [subWalletId] is `null` for the main pocket. The money leaves the
  /// pocket and either tops up an attached bank card ([destinationType]
  /// 'card') or goes to a mobile money wallet ([destinationType] 'momo').
  Future<bool> withdraw({
    String? walletId,
    String? subWalletId,
    required String destinationType,
    String? cardId,
    String? momoId,
    required double amount,
    String note = '',
  }) async {
    if (amount <= 0) return false;
    final wid = _resolveWalletId(walletId);
    final wallet = bloc.walletById(wid);
    if (wallet == null) return false;

    final pocketBalance = subWalletId == null
        ? wallet.mainBalance
        : wallet.subWallets
            .where((w) => w.id == subWalletId)
            .fold(0.0, (s, w) => s + w.balance);
    if (pocketBalance < amount) return false;

    // Destination must exist.
    String? destName;
    String? destNumber;
    if (destinationType == 'card') {
      final card = bloc.cardById(cardId ?? '');
      if (card == null) return false;
      destName = card.nickname;
      destNumber = card.maskedNumber;
    } else if (destinationType == 'momo') {
      final momo = bloc.momoById(momoId ?? '');
      if (momo == null) return false;
      destName = momo.name;
      destNumber = momo.number;
    } else {
      return false;
    }

    // Top up the card, if that's the destination.
    var cards = bloc.cards;
    if (destinationType == 'card' && cardId != null) {
      cards = cards
          .map((c) => c.id == cardId ? c.copyWith(balance: Functions.round2(c.balance + amount)) : c)
          .toList();
    }

    final updated = _withdrawFromPocket(wallet, subWalletId, amount);
    final wallets = bloc.wallets.map((w) => w.id == wid ? updated : w).toList();

    final tx = WalletTransaction(
      id: Functions.generateId(),
      walletId: wid,
      type: 'out',
      amount: amount,
      destinationType: destinationType,
      destinationName: destName,
      destinationNumber: destNumber,
      note: note,
      createdAt: DateTime.now(),
    );

    bloc.setCards(cards);
    await StorageService.saveCards(cards);
    await _persistWallets(wallets);

    final txs = [tx, ...bloc.transactions];
    bloc.setTransactions(txs);
    await StorageService.saveTransactions(txs);
    return true;
  }

  // ---- Banking services (cards only, no wallets) ----

  /// Debits [amount] off a card. Returns `false` when the card is missing
  /// or doesn't have enough money.
  Future<bool> _debitCard(String cardId, double amount) async {
    final idx = bloc.cards.indexWhere((c) => c.id == cardId);
    if (idx == -1 || amount <= 0) return false;
    if (bloc.cards[idx].balance < amount) return false;
    final cards = [...bloc.cards];
    cards[idx] = cards[idx].copyWith(
      balance: Functions.round2(cards[idx].balance - amount),
    );
    bloc.setCards(cards);
    await StorageService.saveCards(cards);
    return true;
  }

  Future<void> _addActivity(ActivityRecord record) async {
    final list = [record, ...bloc.activity];
    bloc.setActivity(list);
    await StorageService.saveActivity(list);
  }

  /// Transfers from an attached card to another bank account or to mobile
  /// money. Wallets are never involved.
  Future<bool> transferOut({
    required String sourceCardId,
    required String destType, // 'bank' | 'momo'
    required double amount,
    String? bankName,
    String? accountNumber,
    String? momoProvider,
    String? momoNumber,
  }) async {
    final bank = bankName?.trim();
    final account = accountNumber?.replaceAll(' ', '').trim();
    final momo = momoNumber?.replaceAll(' ', '');
    if (destType == 'bank' && (bank == null || bank.isEmpty || account == null || account.isEmpty)) {
      return false;
    }
    if (destType == 'momo' && (momoProvider == null || momo == null || momo.isEmpty)) {
      return false;
    }
    if (!await _debitCard(sourceCardId, amount)) return false;

    final destLabel = destType == 'bank'
        ? '$bank • $account'
        : '$momoProvider • $momo';
    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'transfer',
      title: 'Transfer to ${destType == 'bank' ? 'bank account' : 'mobile money'}',
      subtitle: destLabel,
      amount: amount,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Buys airtime for [number] on [network], paid from an attached card.
  Future<bool> buyAirtime({
    required String cardId,
    required String network,
    required String number,
    required double amount,
  }) async {
    if (number.length < 9 || !await _debitCard(cardId, amount)) return false;
    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'airtime',
      title: '$network airtime',
      subtitle: number,
      amount: amount,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Buys a [bundle] of data for the user's own line, paid from a card.
  Future<bool> buyDataBundle({
    required String cardId,
    required DataBundle bundle,
  }) async {
    if (!await _debitCard(cardId, bundle.price)) return false;
    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'data',
      title: '${bundle.provider} ${bundle.size} bundle',
      subtitle: bundle.name,
      amount: bundle.price,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Plans an equal split of [total] across [names]. No money moves yet.
  Future<SplitPayment> createSplit({
    required String title,
    required double total,
    required List<String> names,
  }) async {
    final share = total / names.length;
    final split = SplitPayment(
      id: Functions.generateId(),
      title: title.trim().isEmpty ? 'Bill' : title.trim(),
      total: total,
      people: [
        for (final name in names)
          SplitPerson(name: name.trim().isEmpty ? 'Person ${names.indexOf(name) + 1}' : name.trim(), share: share),
      ],
      createdAt: DateTime.now(),
    );
    final list = [split, ...bloc.splitPayments];
    bloc.setSplitPayments(list);
    await StorageService.saveSplitPayments(list);
    return split;
  }

  /// Creates a money request asking [payerNumber] to send [amount] to the
  /// local user (whoever is signed in).
  Future<MoneyRequest> createMoneyRequest({
    required String payerNumber,
    required double amount,
    String note = '',
  }) async {
    final requester = systemBloc.phone;
    final request = MoneyRequest(
      id: Functions.generateId(),
      requesterNumber: requester,
      requesterName: systemBloc.displayName,
      payerNumber: payerNumber,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );
    final list = [request, ...bloc.moneyRequests];
    bloc.setMoneyRequests(list);
    await StorageService.saveMoneyRequests(list);
    return request;
  }

  /// Pays a pending [requestId] from an attached card. The money moves to
  /// the requester's bank account (recorded locally for now).
  Future<bool> payMoneyRequest({
    required String requestId,
    required String cardId,
  }) async {
    final idx = bloc.moneyRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;
    final request = bloc.moneyRequests[idx];
    if (!request.isPending) return false;
    if (!await _debitCard(cardId, request.amount)) return false;

    final updated = bloc.moneyRequests
        .map((r) => r.id == requestId ? r.copyWith(status: 'paid') : r)
        .toList();
    bloc.setMoneyRequests(updated);
    await StorageService.saveMoneyRequests(updated);

    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'request',
      title: 'Paid ${request.requesterName.isEmpty ? request.requesterNumber : request.requesterName}',
      subtitle: request.requesterNumber,
      amount: request.amount,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Marks a pending request as declined.
  Future<void> declineMoneyRequest(String requestId) async {
    final updated = bloc.moneyRequests
        .map((r) => r.id == requestId && r.isPending
            ? r.copyWith(status: 'declined')
            : r)
        .toList();
    bloc.setMoneyRequests(updated);
    await StorageService.saveMoneyRequests(updated);
  }

  // ---- Wallet-based payments ----

  /// Deducts [amount] from a wallet pocket. Returns `false` if the wallet
  /// or pocket is missing, or the balance is insufficient.
  Future<bool> _deductFromWallet({
    required String walletId,
    String? subWalletId,
    required double amount,
  }) async {
    if (amount <= 0) return false;
    final wallet = bloc.walletById(walletId);
    if (wallet == null) return false;

    final pocketBalance = subWalletId == null
        ? wallet.mainBalance
        : wallet.subWallets
            .where((w) => w.id == subWalletId)
            .fold(0.0, (s, w) => s + w.balance);
    if (pocketBalance < amount) return false;

    final updated = _withdrawFromPocket(wallet, subWalletId, amount);
    final wallets = bloc.wallets.map((w) => w.id == walletId ? updated : w).toList();
    await _persistWallets(wallets);
    return true;
  }

  /// Transfers from a wallet pocket to another bank account or mobile money.
  Future<bool> transferOutFromWallet({
    required String walletId,
    String? subWalletId,
    required String destType,
    required double amount,
    String? bankName,
    String? accountNumber,
    String? momoProvider,
    String? momoNumber,
  }) async {
    final bank = bankName?.trim();
    final account = accountNumber?.replaceAll(' ', '').trim();
    final momo = momoNumber?.replaceAll(' ', '');
    if (destType == 'bank' && (bank == null || bank.isEmpty || account == null || account.isEmpty)) {
      return false;
    }
    if (destType == 'momo' && (momoProvider == null || momo == null || momo.isEmpty)) {
      return false;
    }
    if (!await _deductFromWallet(walletId: walletId, subWalletId: subWalletId, amount: amount)) {
      return false;
    }

    final destLabel = destType == 'bank' ? '$bank • $account' : '$momoProvider • $momo';
    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'transfer',
      title: 'Transfer to ${destType == 'bank' ? 'bank account' : 'mobile money'}',
      subtitle: destLabel,
      amount: amount,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Buys airtime from a wallet pocket.
  Future<bool> buyAirtimeFromWallet({
    required String walletId,
    String? subWalletId,
    required String network,
    required String number,
    required double amount,
  }) async {
    if (number.length < 9) return false;
    if (!await _deductFromWallet(walletId: walletId, subWalletId: subWalletId, amount: amount)) {
      return false;
    }
    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'airtime',
      title: '$network airtime',
      subtitle: number,
      amount: amount,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Buys a data bundle from a wallet pocket.
  Future<bool> buyDataBundleFromWallet({
    required String walletId,
    String? subWalletId,
    required DataBundle bundle,
  }) async {
    if (!await _deductFromWallet(walletId: walletId, subWalletId: subWalletId, amount: bundle.price)) {
      return false;
    }
    await _addActivity(ActivityRecord(
      id: Functions.generateId(),
      kind: 'data',
      title: '${bundle.provider} ${bundle.size} bundle',
      subtitle: bundle.name,
      amount: bundle.price,
      type: 'out',
      createdAt: DateTime.now(),
    ));
    return true;
  }

  /// Removes [amount] from a pocket (or the main pocket when
  /// [subWalletId] is `null`).
  Wallet _withdrawFromPocket(Wallet wallet, String? subWalletId, double amount) {    final total = Functions.round2(wallet.totalBalance - amount);

    if (subWalletId == null) {
      return wallet.copyWith(totalBalance: total);
    }

    final subs = wallet.subWallets.map((w) {
      if (w.id == subWalletId) {
        return w.copyWith(balance: Functions.round2(w.balance - amount));
      }
      return w;
    }).toList();

    return wallet.copyWith(totalBalance: total, subWallets: subs);
  }

  /// Splits a deposit across a wallet's pockets.
  ///
  /// In percentage mode every pocket receives its configured percentage and
  /// the rounding remainder stays with the main pocket. In figures mode the
  /// deposit fills each pocket's target amount one priority at a time (1 is
  /// highest); anything beyond the pockets' combined targets stays in the
  /// main pocket.
  Wallet _depositIntoWallet(Wallet wallet, double amount) {
    final total = Functions.round2(wallet.totalBalance + amount);

    if (wallet.splitMode == 'figures') {
      return _depositByFigures(wallet, amount, total);
    }

    final subs = <SubWallet>[];
    for (final w in wallet.subWallets) {
      final share = Functions.round2(w.shareOf(amount));
      subs.add(w.copyWith(balance: Functions.round2(w.balance + share)));
    }

    return wallet.copyWith(
      totalBalance: total,
      subWallets: subs,
    );
  }

  /// Fills pockets to their [SubWallet.allocation] targets in priority order
  /// (lower priority number first). Any money left over after every pocket
  /// is full stays in the main pocket.
  Wallet _depositByFigures(Wallet wallet, double amount, double total) {
    final ordered = [...wallet.subWallets]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    var remaining = amount;
    final subs = <SubWallet>[];
    for (final w in ordered) {
      double take = 0;
      final cap = w.allocation ?? 0;
      if (remaining > 0) {
        take = remaining < cap ? remaining : cap;
        remaining = Functions.round2(remaining - take);
      }
      subs.add(w.copyWith(balance: Functions.round2(w.balance + take)));
    }

    return wallet.copyWith(
      totalBalance: total,
      subWallets: subs,
    );
  }

  Future<bool> _persistWallet(Wallet wallet) async {
    final wallets = bloc.wallets
        .map((w) => w.id == wallet.id ? wallet : w)
        .toList();
    await _persistWallets(wallets);
    return true;
  }

  /// Records that [amount] was pulled from [cardId] into [walletId]. This
  /// ledger is what lets us refund wallets back to their source cards when
  /// they are deleted.
  Future<void> _recordDeposit({
    required String walletId,
    required String cardId,
    required String cardName,
    required double amount,
  }) async {
    final deposits = [
      WalletDeposit(
        id: Functions.generateId(),
        walletId: walletId,
        cardId: cardId,
        cardName: cardName,
        amount: amount,
        createdAt: DateTime.now(),
      ),
      ...bloc.walletDeposits,
    ];
    await _persistDeposits(deposits);
  }

  Future<void> _persistDeposits(List<WalletDeposit> deposits) async {
    bloc.setWalletDeposits(deposits);
    await StorageService.saveWalletDeposits(deposits);
  }

  /// Puts the [wallet]'s remaining balance back into the cards it was pulled
  /// in from, proportionally to how much each card contributed. Cards that
  /// no longer exist are skipped. The amount refunded is always exactly the
  /// wallet's remaining balance.
  Future<void> _refundWallet(Wallet wallet) async {
    final remaining = wallet.totalBalance;
    if (remaining <= 0) return;

    final byCard = <String, double>{};
    for (final d in bloc.depositsFor(wallet.id)) {
      byCard[d.cardId] = (byCard[d.cardId] ?? 0) + d.amount;
    }

    final live = <String, double>{};
    for (final e in byCard.entries) {
      if (bloc.cardById(e.key) != null) live[e.key] = e.value;
    }
    if (live.isEmpty) return;

    final totalDepCents = live.values.fold<int>(
      0,
      (sum, v) => sum + (v * 100).round(),
    );
    if (totalDepCents <= 0) return;

    final totalCents = (Functions.round2(remaining) * 100).round();

    final refunds = <String, double>{};
    var used = 0;
    final keys = live.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final depCents = (live[key]! * 100).round();
      final isLast = i == keys.length - 1;
      final alloc = isLast
          ? totalCents - used
          : (totalCents * depCents) ~/ totalDepCents;
      used += alloc;
      refunds[key] = alloc / 100;
    }

    final cards = bloc.cards
        .map((c) =>
            refunds.containsKey(c.id)
                ? c.copyWith(balance: Functions.round2(c.balance + refunds[c.id]!))
                : c)
        .toList();
    bloc.setCards(cards);
    await StorageService.saveCards(cards);
  }
}
