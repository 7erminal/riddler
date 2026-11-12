import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ridlers/index.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('transfer splits money by percentages and keeps the books balanced', () async {
    await walletService.load();

    // Card with GH₵ 1000.
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 1000,
      color: 'mint',
    );

    // Pockets: 40% rent + 20% savings => 60% allocated, 40% stays in main.
    await walletService.addSubWallet(
      title: 'Rent',
      purpose: 'Monthly rent',
      percentage: 40,
      color: 'coral',
    );
    await walletService.addSubWallet(
      title: 'Savings',
      purpose: 'Rainy day',
      percentage: 20,
      color: 'sky',
    );

    expect(walletBloc.activeWallet.allocatedPercent, 60);
    expect(walletBloc.activeWallet.remainingPercent, 40);

    // Pull in GH₵ 500 from the card.
    final ok = await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 500);
    expect(ok, isTrue);

    // Card balance drops by the transferred amount.
    expect(walletBloc.cards.first.balance, 500);

    // Wallet total grows.
    expect(walletBloc.activeWallet.totalBalance, 500);

    // Rent gets 40% = 200, Savings gets 20% = 100, main keeps 200.
    final rent = walletBloc.activeWallet.subWallets.firstWhere((w) => w.title == 'Rent');
    final savings = walletBloc.activeWallet.subWallets.firstWhere((w) => w.title == 'Savings');
    expect(rent.balance, 200);
    expect(savings.balance, 100);
    expect(walletBloc.activeWallet.mainBalance, 200);

    // A transaction was recorded.
    expect(walletBloc.transactions.length, 1);
    expect(walletBloc.transactions.first.amount, 500);
  });

  test('cannot allocate more than 100%', () async {
    await walletService.load();
    await walletService.addSubWallet(title: 'A', purpose: '', percentage: 70, color: 'mint');
    final ok = await walletService.addSubWallet(title: 'B', purpose: '', percentage: 40, color: 'sky');
    expect(ok, isFalse);
    expect(walletBloc.activeWallet.allocatedPercent, 70);
  });

  test('transfer fails when the card balance is insufficient', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Card',
      cardNumber: '1234567890123456',
      balance: 50,
      color: 'mint',
    );
    final ok = await walletService.transferFromCard(
      cardId: walletBloc.cards.first.id,
      amount: 500,
    );
    expect(ok, isFalse);
    expect(walletBloc.cards.first.balance, 50);
    expect(walletBloc.activeWallet.totalBalance, 0);
  });

  test('multiple wallets keep separate balances and pockets', () async {
    await walletService.load();

    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 1000,
      color: 'mint',
    );

    // First wallet (created on load) with a 50% pocket.
    await walletService.addSubWallet(title: 'Rent', purpose: '', percentage: 50, color: 'coral');
    final firstId = walletBloc.activeWalletId!;

    // Second wallet, fully independent.
    await walletService.addWallet(name: 'Holiday Fund', color: 'sky');
    final secondId = walletBloc.activeWalletId!;
    expect(firstId, isNot(secondId));
    await walletService.addSubWallet(
      walletId: secondId,
      title: 'Flights',
      purpose: '',
      percentage: 100,
      color: 'sky',
    );

    // Pull money into the second wallet only.
    final ok = await walletService.transferFromCard(
      walletId: secondId,
      cardId: walletBloc.cards.first.id,
      amount: 400,
    );
    expect(ok, isTrue);

    expect(walletBloc.walletById(firstId)!.totalBalance, 0);
    expect(walletBloc.walletById(secondId)!.totalBalance, 400);
    expect(walletBloc.walletById(secondId)!.subWallets.single.balance, 400);
    expect(walletBloc.walletById(firstId)!.subWallets.single.balance, 0);
    expect(walletBloc.cards.first.balance, 600);

    // Transactions are tagged to the right wallet.
    expect(walletBloc.transactionsFor(secondId).length, 1);
    expect(walletBloc.transactionsFor(firstId), isEmpty);

    // Deleting the active wallet falls back to the remaining one.
    await walletService.deleteWallet(secondId);
    expect(walletBloc.wallets.length, 1);
    expect(walletBloc.activeWalletId, firstId);
  });

  test('data persists across reloads', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'CalBank',
      nickname: 'Groceries',
      cardNumber: '9876543210987654',
      balance: 250,
      color: 'coral',
    );
    await walletService.addSubWallet(title: 'Food', purpose: '', percentage: 30, color: 'lemon');
    await walletService.addWallet(name: 'Emergency', color: 'coral');

    // Simulate a fresh app start: new bloc/service reading the same storage.
    final freshBloc = WalletBloc();
    final freshService = WalletService(freshBloc);
    await freshService.load();

    expect(freshBloc.cards.length, 1);
    expect(freshBloc.cards.first.nickname, 'Groceries');
    expect(freshBloc.wallets.length, 2);
    expect(freshBloc.wallets.first.subWallets.length, 1);
    expect(freshBloc.wallets.first.subWallets.first.title, 'Food');
    expect(freshBloc.wallets[1].name, 'Emergency');
  });

  test('legacy single-wallet storage is migrated to a list', () async {
    SharedPreferences.setMockInitialValues({
      'ridlers_wallet':
          '{"id":"legacy","name":"Old Wallet","subWallets":[],"totalBalance":120.0,"createdAt":"2026-01-01T00:00:00.000"}',
    });
    await walletService.load();
    expect(walletBloc.wallets.length, 1);
    expect(walletBloc.activeWallet.name, 'Old Wallet');
    expect(walletBloc.activeWallet.totalBalance, 120);
  });

  test('withdraw from the main pocket tops up the card', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 1000,
      color: 'mint',
    );
    // Fund the wallet straight away (no pockets => everything stays in main).
    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 300);
    expect(walletBloc.activeWallet.mainBalance, 300);

    final ok = await walletService.withdraw(
      subWalletId: null,
      destinationType: 'card',
      cardId: walletBloc.cards.first.id,
      amount: 120,
    );
    expect(ok, isTrue);

    expect(walletBloc.activeWallet.totalBalance, 180);
    expect(walletBloc.activeWallet.mainBalance, 180);
    expect(walletBloc.cards.first.balance, 820);

    final tx = walletBloc.transactions.first;
    expect(tx.type, 'out');
    expect(tx.destinationType, 'card');
    expect(tx.destinationName, 'Salary');
    expect(tx.amount, 120);
  });

  test('withdraw from a pocket to mobile money leaves cards untouched', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 500,
      color: 'mint',
    );
    await walletService.addSubWallet(title: 'Fun', purpose: '', percentage: 50, color: 'pink');
    await walletService.addMoMo(
      provider: 'MTN',
      name: 'MTN line',
      number: '0241234567',
      color: 'yellow',
    );
    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 200);

    final pocket = walletBloc.activeWallet.subWallets.single;
    final momoId = walletBloc.momoWallets.single.id;
    final cardBalanceBefore = walletBloc.cards.first.balance;

    final ok = await walletService.withdraw(
      subWalletId: pocket.id,
      destinationType: 'momo',
      momoId: momoId,
      amount: 50,
    );
    expect(ok, isTrue);

    expect(walletBloc.activeWallet.subWallets.single.balance, 50);
    expect(walletBloc.activeWallet.totalBalance, 150);
    expect(walletBloc.cards.first.balance, cardBalanceBefore);

    final tx = walletBloc.transactions.first;
    expect(tx.destinationType, 'momo');
    expect(tx.destinationName, 'MTN line');
    expect(tx.destinationNumber, '0241234567');
  });

  test('withdraw fails when the pocket has too little', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 100,
      color: 'mint',
    );
    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 40);
    final txsBefore = walletBloc.transactions.length;

    final ok = await walletService.withdraw(
      subWalletId: null,
      destinationType: 'card',
      cardId: walletBloc.cards.first.id,
      amount: 100,
    );
    expect(ok, isFalse);
    expect(walletBloc.activeWallet.totalBalance, 40);
    expect(walletBloc.cards.first.balance, 60);
    expect(walletBloc.transactions.length, txsBefore);
  });

  test('withdraw fails when the destination does not exist', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 100,
      color: 'mint',
    );
    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 40);
    final txsBefore = walletBloc.transactions.length;

    final ok = await walletService.withdraw(
      subWalletId: null,
      destinationType: 'momo',
      momoId: 'missing',
      amount: 10,
    );
    expect(ok, isFalse);
    expect(walletBloc.activeWallet.totalBalance, 40);
    expect(walletBloc.transactions.length, txsBefore);
  });

  test('mobile money wallets persist across reloads', () async {
    await walletService.load();
    await walletService.addMoMo(
      provider: 'Telecel',
      name: 'Telecel line',
      number: '0551234567',
      color: 'sky',
    );
    expect(walletBloc.momoWallets.length, 1);

    final freshBloc = WalletBloc();
    final freshService = WalletService(freshBloc);
    await freshService.load();

    expect(freshBloc.momoWallets.length, 1);
    expect(freshBloc.momoWallets.single.provider, 'Telecel');
    expect(freshBloc.momoWallets.single.number, '0551234567');

    await freshService.deleteMoMo(freshBloc.momoWallets.single.id);
    expect(freshBloc.momoWallets, isEmpty);
  });

  test('deposits are tracked per wallet for refunding later', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 1000,
      color: 'mint',
    );
    await walletService.addWallet(name: 'Budget', color: 'sky');
    final walletId = walletBloc.activeWalletId!;

    await walletService.transferFromCard(
      walletId: walletId,
      cardId: walletBloc.cards.first.id,
      amount: 200,
    );
    await walletService.withdrawFromCard(
      cardId: walletBloc.cards.first.id,
      amount: 50,
    );

    // transferFromCard -> the Budget wallet, withdrawFromCard -> the default one.
    expect(walletBloc.walletDeposits.length, 2);
    final budgetDeposits = walletBloc.depositsFor(walletId);
    expect(budgetDeposits.single.amount, 200);
    expect(budgetDeposits.single.cardId, walletBloc.cards.first.id);
    expect(budgetDeposits.single.cardName, 'Salary');
    expect(walletBloc.depositsFor(walletBloc.wallets.first.id).single.amount, 50);
  });

  test('deposits persist across reloads', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 500,
      color: 'mint',
    );
    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 120);

    final freshBloc = WalletBloc();
    final freshService = WalletService(freshBloc);
    await freshService.load();

    expect(freshBloc.walletDeposits.single.amount, 120);
    expect(freshBloc.walletDeposits.single.cardName, 'Salary');
  });

  test('deleting a wallet refunds its balance to the source cards', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 1000,
      color: 'mint',
    );
    await walletService.addCard(
      bankName: 'CalBank',
      nickname: 'Groceries',
      cardNumber: '9876543210987654',
      balance: 1000,
      color: 'coral',
    );
    await walletService.addWallet(name: 'Budget', color: 'sky');
    final walletId = walletBloc.activeWalletId!;

    await walletService.transferFromCard(
      walletId: walletId,
      cardId: walletBloc.cards[0].id,
      amount: 300,
    );
    await walletService.transferFromCard(
      walletId: walletId,
      cardId: walletBloc.cards[1].id,
      amount: 100,
    );
    // Withdraw half of it back to card A only, so 200 remains to be refunded
    // (the withdrawal also tops card A back up by 200).
    await walletService.withdraw(
      walletId: walletId,
      subWalletId: null,
      destinationType: 'card',
      cardId: walletBloc.cards[0].id,
      amount: 200,
    );

    expect(walletBloc.walletById(walletId)!.totalBalance, 200);
    final aAfterWithdraw = walletBloc.cards[0].balance; // 1000 - 300 + 200 = 900
    final bAfterWithdraw = walletBloc.cards[1].balance; // 1000 - 100 = 900

    await walletService.deleteWallet(walletId);
    expect(walletBloc.walletById(walletId), isNull);
    expect(walletBloc.wallets.length, 1);

    // 200 left, split 3:1 -> card A +150, card B +50.
    expect(walletBloc.cards[0].balance, aAfterWithdraw + 150);
    expect(walletBloc.cards[1].balance, bAfterWithdraw + 50);
    expect(walletBloc.depositsFor(walletId), isEmpty);
  });

  test('deleting a wallet refunds only to cards that still exist', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 500,
      color: 'mint',
    );
    await walletService.addCard(
      bankName: 'CalBank',
      nickname: 'Groceries',
      cardNumber: '9876543210987654',
      balance: 500,
      color: 'coral',
    );
    await walletService.addWallet(name: 'Budget', color: 'sky');
    final walletId = walletBloc.activeWalletId!;

    await walletService.transferFromCard(
      walletId: walletId,
      cardId: walletBloc.cards[0].id,
      amount: 100,
    );
    await walletService.transferFromCard(
      walletId: walletId,
      cardId: walletBloc.cards[1].id,
      amount: 100,
    );
    await walletService.deleteCard(walletBloc.cards[1].id);

    await walletService.deleteWallet(walletId);

    // Only the surviving card can be refunded, and gets the full remaining 200.
    expect(walletBloc.cards.length, 1);
    expect(walletBloc.cards[0].balance, 500 - 100 + 200);
  });

  test('deleting the last wallet is allowed', () async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 500,
      color: 'mint',
    );
    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 100);

    await walletService.deleteWallet(walletBloc.activeWalletId!);
    expect(walletBloc.wallets, isEmpty);
    expect(walletBloc.activeWallet.name, 'My Wallet'); // placeholder fallback
    expect(walletBloc.cards.first.balance, 500); // refunded fully
  });
}
