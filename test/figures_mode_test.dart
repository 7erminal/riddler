import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ridlers/index.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> addCard() async {
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: 10000,
      color: 'mint',
    );
  }

  Future<void> seedFiguresWallet() async {
    await walletService.load();
    await walletService.addWallet(name: 'Figures', color: 'sky', splitMode: 'figures');
    await walletService.addSubWallet(title: 'Light', purpose: '', percentage: 0, color: 'amber', allocation: 700);
    await walletService.addSubWallet(title: 'Water', purpose: '', percentage: 0, color: 'sky', allocation: 500);
    await walletService.addSubWallet(title: 'Food', purpose: '', percentage: 0, color: 'coral', allocation: 800);
    await walletService.addSubWallet(title: 'Fuel', purpose: '', percentage: 0, color: 'lime', allocation: 1500);
    await addCard();
  }

  double pocket(String title) =>
      walletBloc.activeWallet.subWallets.firstWhere((w) => w.title == title).balance;

  test('figures wallet stores its split mode and persists it', () async {
    await walletService.load();
    await walletService.addWallet(name: 'Figures', color: 'sky', splitMode: 'figures');
    expect(walletBloc.activeWallet.splitMode, 'figures');

    await walletService.load();
    final figures = walletBloc.wallets.firstWhere((w) => w.name == 'Figures');
    expect(figures.splitMode, 'figures');
  });

  test('figures pockets default to next priority and refuse invalid inputs', () async {
    await walletService.load();
    await walletService.addWallet(name: 'Figures', color: 'sky', splitMode: 'figures');

    await walletService.addSubWallet(title: 'A', purpose: '', percentage: 0, color: 'amber', allocation: 100);
    await walletService.addSubWallet(title: 'B', purpose: '', percentage: 0, color: 'sky', allocation: 200);
    await walletService.addSubWallet(title: 'C', purpose: '', percentage: 0, color: 'coral', allocation: 300, priority: 1);

    expect(walletBloc.activeWallet.subWallets[0].priority, 1);
    expect(walletBloc.activeWallet.subWallets[1].priority, 2);
    expect(walletBloc.activeWallet.subWallets[2].priority, 1);

    final noAllocation = await walletService.addSubWallet(title: 'D', purpose: '', percentage: 0, color: 'lime');
    expect(noAllocation, isFalse);
    expect(walletBloc.activeWallet.subWallets.length, 3);
  });

  test('full deposit fills every pocket to its target', () async {
    await seedFiguresWallet();

    final ok = await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 3500);
    expect(ok, isTrue);

    expect(pocket('Light'), 700);
    expect(pocket('Water'), 500);
    expect(pocket('Food'), 800);
    expect(pocket('Fuel'), 1500);
    expect(walletBloc.activeWallet.mainBalance, 0);
    expect(walletBloc.activeWallet.totalBalance, 3500);
  });

  test('partial deposit fills pockets in priority order', () async {
    await seedFiguresWallet();

    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 1200);

    expect(pocket('Light'), 700);
    expect(pocket('Water'), 500);
    expect(pocket('Food'), 0);
    expect(pocket('Fuel'), 0);
    expect(walletBloc.activeWallet.mainBalance, 0);
  });

  test('deposit smaller than the top priority goes entirely to that pocket', () async {
    await seedFiguresWallet();

    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 300);

    expect(pocket('Light'), 300);
    expect(pocket('Water'), 0);
    expect(pocket('Food'), 0);
    expect(pocket('Fuel'), 0);
    expect(walletBloc.activeWallet.mainBalance, 0);
  });

  test('deposit can be split across only some priorities with balance left for the next', () async {
    await seedFiguresWallet();

    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 1600);

    expect(pocket('Light'), 700);
    expect(pocket('Water'), 500);
    expect(pocket('Food'), 400);
    expect(pocket('Fuel'), 0);
    expect(walletBloc.activeWallet.mainBalance, 0);
  });

  test('amounts beyond the combined targets stay in the main pocket', () async {
    await seedFiguresWallet();

    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 4000);

    expect(pocket('Light'), 700);
    expect(pocket('Water'), 500);
    expect(pocket('Food'), 800);
    expect(pocket('Fuel'), 1500);
    expect(walletBloc.activeWallet.mainBalance, 500);
  });

  test('changing priorities reorders where future deposits land', () async {
    await seedFiguresWallet();

    // Swap Light and Water so Water is filled first.
    final water = walletBloc.activeWallet.subWallets.firstWhere((w) => w.title == 'Water');
    final light = walletBloc.activeWallet.subWallets.firstWhere((w) => w.title == 'Light');
    await walletService.updateSubWallet(updated: water.copyWith(priority: 1));
    await walletService.updateSubWallet(updated: light.copyWith(priority: 2));

    await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 1000);

    expect(pocket('Water'), 500);
    expect(pocket('Light'), 500);
    expect(pocket('Food'), 0);
  });

  test('reordering priorities is persistent', () async {
    await seedFiguresWallet();

    final light = walletBloc.activeWallet.subWallets.firstWhere((w) => w.title == 'Light');
    await walletService.updateSubWallet(updated: light.copyWith(priority: 4));

    await walletService.load();
    final reloaded = walletBloc.wallets.firstWhere((w) => w.name == 'Figures');
    final reloadedLight = reloaded.subWallets.firstWhere((w) => w.title == 'Light');
    expect(reloadedLight.priority, 4);
    expect(reloadedLight.allocation, 700);
  });

  test('percent wallets ignore figures-mode fields', () async {
    await walletService.load();
    await addCard();

    await walletService.addSubWallet(
      title: 'A',
      purpose: '',
      percentage: 50,
      color: 'mint',
      allocation: 999,
      priority: 77,
    );

    final sub = walletBloc.activeWallet.subWallets.first;
    expect(sub.allocation, isNull);
    expect(sub.priority, 1);
    expect(sub.percentage, 50);

    final ok = await walletService.transferFromCard(cardId: walletBloc.cards.first.id, amount: 500);
    expect(ok, isTrue);
    expect(walletBloc.activeWallet.subWallets.first.balance, 250);
  });
}