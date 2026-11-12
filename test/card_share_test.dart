import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ridlers/index.dart';

void main() {
  const owner = '0240000000';
  const invitee = '0551112222';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    systemBloc = SystemBloc();
    walletBloc = WalletBloc();
    walletService = WalletService(walletBloc);
    groupWalletService = GroupWalletService(walletBloc);
    cardShareService = CardShareService(walletBloc);
    systemBloc.phone = owner;
    await StorageService.saveUser({
      'phone': owner,
      'pin': '4321',
      'createdAt': DateTime.now().toIso8601String(),
    });
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

  BankCard cardOf(String cardId) => walletBloc.cardById(cardId)!;

  Future<CardShare> shareWithInvitee({double balance = 500}) async {
    final card = cardOf(await addCard(balance: balance));
    final share = await cardShareService.shareCard(
      cardId: card.id,
      cardName: card.nickname,
      cardBankName: card.bankName,
      cardLast4: card.last4,
      cardColor: card.color,
      inviteePhone: invitee,
      pin: '4321',
    );
    return share!;
  }

  test('shareCard creates a pending invitation for the invitee', () async {
    final share = await shareWithInvitee();

    expect(share.isPending, isTrue);
    expect(share.ownerPhone, owner);
    expect(share.inviteePhone, invitee);
    expect(walletBloc.cardShares.single.id, share.id);

    systemBloc.phone = invitee;
    expect(walletBloc.pendingShareInvitations.single.id, share.id);
  });

  test('shareCard refuses a wrong PIN and creates nothing', () async {
    final card = cardOf(await addCard());

    final share = await cardShareService.shareCard(
      cardId: card.id,
      cardName: card.nickname,
      cardBankName: card.bankName,
      cardLast4: card.last4,
      cardColor: card.color,
      inviteePhone: invitee,
      pin: '9999',
    );

    expect(share, isNull);
    expect(walletBloc.cardShares, isEmpty);
  });

  test('acceptShare lets the invitee see the shared card', () async {
    final share = await shareWithInvitee();
    final card = cardOf(share.cardId);
    systemBloc.phone = invitee;

    expect(walletBloc.acceptedSharesWithMe, isEmpty);
    expect(walletBloc.sharedCardsWithMe, isEmpty);

    await cardShareService.acceptShare(share.id);

    expect(walletBloc.acceptedSharesWithMe.single.id, share.id);
    expect(walletBloc.pendingShareInvitations, isEmpty);
    final shared = walletBloc.sharedCardsWithMe.single;
    expect(shared.id, card.id);
    expect(shared.isShared, isTrue);
    expect(shared.isPrimary, isFalse);
    expect(shared.nickname, contains('(shared)'));
    expect(shared.balance, card.balance);
  });

  test('rejectShare marks the invitation rejected', () async {
    final share = await shareWithInvitee();
    systemBloc.phone = invitee;

    await cardShareService.rejectShare(share.id);

    expect(walletBloc.cardShares.single.isRejected, isTrue);
    expect(walletBloc.pendingShareInvitations, isEmpty);
    expect(walletBloc.sharedCardsWithMe, isEmpty);
  });

  test('invitee can request a withdrawal from a shared card', () async {
    final share = await shareWithInvitee();
    await cardShareService.acceptShare(share.id);
    systemBloc.phone = invitee;

    final request = await cardShareService.requestWithdrawal(
      cardId: share.cardId,
      cardName: share.cardName,
      cardBankName: share.cardBankName,
      cardLast4: share.cardLast4,
      ownerPhone: owner,
      amount: 120,
    );

    expect(request.isPending, isTrue);
    expect(request.requesterPhone, invitee);
    expect(walletBloc.withdrawalRequests.single.id, request.id);

    systemBloc.phone = owner;
    expect(walletBloc.pendingWithdrawalApprovals.single.id, request.id);
  });

  test('owner approving a withdrawal moves money to the wallet', () async {
    final share = await shareWithInvitee();
    await cardShareService.acceptShare(share.id);
    final walletBefore = walletBloc.wallets.first.totalBalance;
    final request = await cardShareService.requestWithdrawal(
      cardId: share.cardId,
      cardName: share.cardName,
      cardBankName: share.cardBankName,
      cardLast4: share.cardLast4,
      ownerPhone: owner,
      amount: 120,
    );

    expect(await cardShareService.approveWithdrawal(request.id, pin: '9999'), isFalse);
    expect(walletBloc.cards.first.balance, 500);
    expect(walletBloc.wallets.first.totalBalance, walletBefore);
    expect(walletBloc.withdrawalRequests.first.isPending, isTrue);

    expect(await cardShareService.approveWithdrawal(request.id, pin: '4321'), isTrue);
    expect(walletBloc.cards.first.balance, 380);
    expect(walletBloc.wallets.first.totalBalance, walletBefore + 120);
    expect(walletBloc.withdrawalRequests.first.isAccepted, isTrue);
    expect(walletBloc.pendingWithdrawalApprovals, isEmpty);
    expect(walletBloc.activity.first.kind, 'withdraw');
    expect(walletBloc.activity.first.amount, 120);
  });

  test('approval fails when the card cannot cover the amount', () async {
    final share = await shareWithInvitee(balance: 30);
    await cardShareService.acceptShare(share.id);
    final walletBefore = walletBloc.wallets.first.totalBalance;
    final request = await cardShareService.requestWithdrawal(
      cardId: share.cardId,
      cardName: share.cardName,
      cardBankName: share.cardBankName,
      cardLast4: share.cardLast4,
      ownerPhone: owner,
      amount: 100,
    );

    expect(await cardShareService.approveWithdrawal(request.id, pin: '4321'), isFalse);
    expect(walletBloc.cards.first.balance, 30);
    expect(walletBloc.wallets.first.totalBalance, walletBefore);
    expect(walletBloc.withdrawalRequests.first.isPending, isTrue);
  });

  test('card shares and withdrawal requests persist across reloads', () async {
    final share = await shareWithInvitee();
    await cardShareService.acceptShare(share.id);
    final request = await cardShareService.requestWithdrawal(
      cardId: share.cardId,
      cardName: share.cardName,
      cardBankName: share.cardBankName,
      cardLast4: share.cardLast4,
      ownerPhone: owner,
      amount: 50,
    );

    final freshBloc = WalletBloc();
    final freshWalletService = WalletService(freshBloc);
    await freshWalletService.load();
    systemBloc.phone = invitee;
    final freshShareService = CardShareService(freshBloc);
    await freshShareService.load();

    expect(freshBloc.cardShares.single.isAccepted, isTrue);
    expect(freshBloc.sharedCardsWithMe.single.isShared, isTrue);
    expect(freshBloc.withdrawalRequests.single.id, request.id);
  });
}