import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ridlers/index.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<String> addCard({double balance = 500}) async {
    await walletService.load();
    await walletService.addCard(
      bankName: 'GCB',
      nickname: 'Salary',
      cardNumber: '5399838383839999',
      balance: balance,
      color: 'mint',
    );
    return walletBloc.cards.first.id;
  }

  test('transferOut to a bank account debits the card', () async {
    final cardId = await addCard();

    final ok = await walletService.transferOut(
      sourceCardId: cardId,
      destType: 'bank',
      amount: 200,
      bankName: 'CalBank',
      accountNumber: '0221012345678',
    );
    expect(ok, isTrue);
    expect(walletBloc.cards.first.balance, 300);
    expect(walletBloc.activity.length, 1);
    expect(walletBloc.activity.first.kind, 'transfer');
    expect(walletBloc.activity.first.amount, 200);
    expect(walletBloc.activity.first.subtitle, 'CalBank • 0221012345678');
  });

  test('transferOut to mobile money debits the card', () async {
    final cardId = await addCard();

    final ok = await walletService.transferOut(
      sourceCardId: cardId,
      destType: 'momo',
      amount: 50,
      momoProvider: 'MTN',
      momoNumber: '0241234567',
    );
    expect(ok, isTrue);
    expect(walletBloc.cards.first.balance, 450);
    expect(walletBloc.activity.first.subtitle, 'MTN • 0241234567');
  });

  test('transferOut fails without funds or an invalid destination', () async {
    final cardId = await addCard(balance: 30);

    final overLimit = await walletService.transferOut(
      sourceCardId: cardId,
      destType: 'bank',
      amount: 100,
      bankName: 'GCB',
      accountNumber: '1111',
    );
    expect(overLimit, isFalse);
    expect(walletBloc.cards.first.balance, 30);

    final missingBank = await walletService.transferOut(
      sourceCardId: cardId,
      destType: 'bank',
      amount: 10,
      bankName: '',
      accountNumber: '',
    );
    expect(missingBank, isFalse);

    final missingMomo = await walletService.transferOut(
      sourceCardId: cardId,
      destType: 'momo',
      amount: 10,
    );
    expect(missingMomo, isFalse);

    expect(walletBloc.activity, isEmpty);
  });

  test('buyAirtime debits the card and records the number', () async {
    final cardId = await addCard();

    final ok = await walletService.buyAirtime(
      cardId: cardId,
      network: 'MTN',
      number: '0551234567',
      amount: 20,
    );
    expect(ok, isTrue);
    expect(walletBloc.cards.first.balance, 480);
    expect(walletBloc.activity.first.kind, 'airtime');
    expect(walletBloc.activity.first.title, 'MTN airtime');
    expect(walletBloc.activity.first.subtitle, '0551234567');
  });

  test('buyAirtime fails for a bad number', () async {
    final cardId = await addCard();
    final ok = await walletService.buyAirtime(
      cardId: cardId,
      network: 'MTN',
      number: '123',
      amount: 20,
    );
    expect(ok, isFalse);
    expect(walletBloc.cards.first.balance, 500);
    expect(walletBloc.activity, isEmpty);
  });

  test('buyDataBundle debits the card by the bundle price', () async {
    final cardId = await addCard();
    final bundle = dataBundles['MTN']!.first; // 0.5GB for GH₵ 5

    final ok = await walletService.buyDataBundle(cardId: cardId, bundle: bundle);
    expect(ok, isTrue);
    expect(walletBloc.cards.first.balance, 495);
    expect(walletBloc.activity.first.kind, 'data');
    expect(walletBloc.activity.first.amount, 5);
  });

  test('createSplit plans an equal split between people', () async {
    await walletService.load();
    final split = await walletService.createSplit(
      title: 'Dinner',
      total: 300,
      names: ['Ama', 'Kofi', 'Yaw'],
    );
    expect(split.people.length, 3);
    expect(split.sharePerPerson, 100);
    expect(walletBloc.splitPayments.length, 1);
    expect(walletBloc.splitPayments.first.total, 300);
  });

  test('money request is paid from the payer card and marked done', () async {
    final cardId = await addCard();

    final request = await walletService.createMoneyRequest(
      payerNumber: '0241234567',
      amount: 150,
      note: 'Lunch',
    );
    expect(request.isPending, isTrue);
    expect(request.link, 'ridlers://pay/${request.id}');
    expect(walletBloc.pendingRequests.length, 1);

    final paid = await walletService.payMoneyRequest(
      requestId: request.id,
      cardId: cardId,
    );
    expect(paid, isTrue);
    expect(walletBloc.cards.first.balance, 350);
    expect(walletBloc.moneyRequests.first.isPaid, isTrue);
    expect(walletBloc.pendingRequests, isEmpty);
    expect(walletBloc.activity.first.kind, 'request');
    expect(walletBloc.activity.first.amount, 150);
  });

  test('paying an already paid request does nothing twice', () async {
    final cardId = await addCard();
    final request = await walletService.createMoneyRequest(
      payerNumber: '0241234567',
      amount: 50,
    );

    expect(await walletService.payMoneyRequest(requestId: request.id, cardId: cardId), isTrue);
    expect(walletBloc.cards.first.balance, 450);
    expect(await walletService.payMoneyRequest(requestId: request.id, cardId: cardId), isFalse);
    expect(walletBloc.cards.first.balance, 450);
  });

  test('declined requests leave money untouched', () async {
    final cardId = await addCard();
    final request = await walletService.createMoneyRequest(
      payerNumber: '0241234567',
      amount: 80,
    );
    await walletService.declineMoneyRequest(request.id);

    expect(walletBloc.moneyRequests.first.isPending, isFalse);
    expect(walletBloc.pendingRequests, isEmpty);
    expect(walletBloc.cards.first.balance, 500);

    expect(await walletService.payMoneyRequest(requestId: request.id, cardId: cardId), isFalse);
  });

  test('verifyPin checks against the stored user PIN', () async {
    await StorageService.saveUser({
      'phone': '0240000000',
      'pin': '4321',
      'createdAt': DateTime.now().toIso8601String(),
    });
    expect(await authService.verifyPin('4321'), isTrue);
    expect(await authService.verifyPin('9999'), isFalse);
  });

  test('services data persists across reloads', () async {
    final cardId = await addCard();
    await walletService.buyAirtime(cardId: cardId, network: 'Telecel', number: '0551112222', amount: 10);
    final request = await walletService.createMoneyRequest(payerNumber: '0203334444', amount: 40);
    await walletService.createSplit(title: 'Taxi', total: 60, names: ['A', 'B']);

    final freshBloc = WalletBloc();
    final freshService = WalletService(freshBloc);
    await freshService.load();

    expect(freshBloc.activity.length, 1);
    expect(freshBloc.activity.first.subtitle, '0551112222');
    expect(freshBloc.moneyRequests.single.id, request.id);
    expect(freshBloc.splitPayments.single.total, 60);
  });
}
