import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ridlers/index.dart';

void main() {
  const owner = '0240000000';
  const another = '0551112222';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    systemBloc = SystemBloc();
    walletBloc = WalletBloc();
    walletService = WalletService(walletBloc);
    groupWalletService = GroupWalletService(walletBloc);
    cardShareService = CardShareService(walletBloc);
    systemBloc.phone = owner;
  });

  Future<GroupWallet> createGroup() {
    return groupWalletService.createGroupWallet(
      name: 'School Run',
      color: 'sky',
      memberPhones: [another],
    );
  }

  test('owner can add a pending member to a group wallet', () async {
    final gw = await createGroup();

    final ok = await groupWalletService.addMember(gw.id, '0201122334');
    expect(ok, isTrue);

    final updated = walletBloc.groupWalletById(gw.id)!;
    expect(updated.members.length, 3);
    final added = updated.members.last;
    expect(added.phone, '0201122334');
    expect(added.isPending, isTrue);
    expect(updated.pendingMembers.length, 2);

    // The invitee now sees a pending invitation.
    systemBloc.phone = '0201122334';
    expect(walletBloc.pendingGroupInvitations.map((w) => w.id), contains(gw.id));
  });

  test('addMember rejects invalid, duplicate, and owner phones', () async {
    final gw = await createGroup();

    expect(await groupWalletService.addMember(gw.id, '123'), isFalse);
    expect(await groupWalletService.addMember(gw.id, another), isFalse);
    expect(await groupWalletService.addMember(gw.id, owner), isFalse);

    final updated = walletBloc.groupWalletById(gw.id)!;
    expect(updated.members.length, 2);
  });

  test('only the owner can delete a group wallet', () async {
    final gw = await createGroup();

    systemBloc.phone = another;
    await groupWalletService.deleteGroupWallet(gw.id);
    expect(walletBloc.groupWalletById(gw.id), isNotNull);

    systemBloc.phone = owner;
    await groupWalletService.deleteGroupWallet(gw.id);
    expect(walletBloc.groupWalletById(gw.id), isNull);
    expect(walletBloc.groupWallets, isEmpty);
  });

  test('group wallets and members persist across reloads', () async {
    final gw = await createGroup();
    await groupWalletService.addMember(gw.id, '0201122334');

    final freshBloc = WalletBloc();
    final freshService = GroupWalletService(freshBloc);
    await freshService.load();

    expect(freshBloc.groupWallets.single.name, 'School Run');
    expect(freshBloc.groupWallets.single.members.length, 3);
    expect(
      freshBloc.groupWallets.single.members.map((m) => m.phone),
      contains('0201122334'),
    );
  });
}