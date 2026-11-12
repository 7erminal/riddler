import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Bottom sheet: create a brand new main wallet.
Future<void> showAddWalletSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddWalletSheet(),
  );
}

class _AddWalletSheet extends StatefulWidget {
  const _AddWalletSheet();

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final _name = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _color = 'mint';
  String _error = '';
  bool _isGroup = false;
  String _splitMode = 'percent';
  final List<String> _memberPhones = [];

  @override
  void dispose() {
    _name.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _addPhone() {
    final raw = _phoneCtrl.text.trim().replaceAll(' ', '');
    if (raw.length < 9) {
      setState(() => _error = 'Enter a valid phone number (at least 9 digits).');
      return;
    }
    if (_memberPhones.contains(raw)) {
      setState(() => _error = 'That number is already added.');
      return;
    }
    setState(() {
      _memberPhones.add(raw);
      _phoneCtrl.clear();
      _error = '';
    });
  }

  void _removePhone(int index) {
    setState(() => _memberPhones.removeAt(index));
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give your wallet a name.');
      return;
    }
    if (_isGroup && _memberPhones.isEmpty) {
      setState(() => _error = 'Add at least one member to the group.');
      return;
    }
    if (_isGroup) {
      await groupWalletService.createGroupWallet(
        name: _name.text.trim(),
        color: _color,
        memberPhones: _memberPhones,
        splitMode: _splitMode,
      );
    } else {
      await walletService.addWallet(
        name: _name.text.trim(),
        color: _color,
        splitMode: _splitMode,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isGroup
              ? '${_name.text.trim()} group wallet created 🎉'
              : '${_name.text.trim()} wallet created 🎉',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: Icon(
                  _isGroup ? Icons.group_rounded : Icons.add_circle_outline_rounded,
                  color: AppTheme.ink,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isGroup ? 'New group wallet' : 'New wallet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              _isGroup
                  ? 'A shared wallet for you and your group members.'
                  : 'A separate wallet with its own 100% and its own pockets.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // ---- Individual / Group toggle ----
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isGroup = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isGroup ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outline, width: 2.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_rounded, size: 18, color: AppTheme.ink),
                          const SizedBox(width: 6),
                          Text(
                            'Individual',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isGroup = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isGroup ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outline, width: 2.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_rounded, size: 18, color: AppTheme.ink),
                          const SizedBox(width: 6),
                          Text(
                            'Group',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---- Split mode toggle ----
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _splitMode = 'percent'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _splitMode == 'percent' ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outline, width: 2.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.percent_rounded, size: 18, color: AppTheme.ink),
                          const SizedBox(height: 4),
                          Text(
                            'Percentages',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _splitMode = 'figures'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _splitMode == 'figures' ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.outline, width: 2.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pin_rounded, size: 18, color: AppTheme.ink),
                          const SizedBox(height: 4),
                          Text(
                            'Set figures',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _splitMode == 'percent'
                  ? 'Each pocket takes a fixed % of every deposit.'
                  : 'Give each pocket a set amount; deposits fill the highest-priority pocket first.',
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 12, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),

            // ---- Wallet name ----
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Wallet name',
                hintText: 'e.g. Family Fund',
                prefixIcon: Icon(Icons.savings_rounded),
              ),
            ),
            const SizedBox(height: 18),

            // ---- Colour ----
            const Text(
              'Wallet colour',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),

            // ---- Group: member phone input ----
            if (_isGroup) ...[
              const SizedBox(height: 20),
              const Text(
                'Members',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                      onSubmitted: (_) => _addPhone(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  StickerButton(
                    onTap: _addPhone,
                    color: AppTheme.mint,
                    radius: 14,
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.add_rounded, color: AppTheme.ink, size: 22),
                  ),
                ],
              ),
              if (_memberPhones.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < _memberPhones.length; i++)
                      Sticker(
                        color: AppTheme.surface,
                        radius: 14,
                        dy: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_rounded, size: 14, color: AppTheme.inkSoft),
                            const SizedBox(width: 6),
                            Text(
                              _memberPhones[i],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.ink),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removePhone(i),
                              child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.inkFaint),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                _isGroup ? 'Create group wallet' : 'Create wallet',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: add a new member to a group wallet.
Future<void> showAddGroupMemberSheet(BuildContext context, {required String groupWalletId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddGroupMemberSheet(groupWalletId: groupWalletId),
  );
}

class _AddGroupMemberSheet extends StatefulWidget {
  final String groupWalletId;

  const _AddGroupMemberSheet({required this.groupWalletId});

  @override
  State<_AddGroupMemberSheet> createState() => _AddGroupMemberSheetState();
}

class _AddGroupMemberSheetState extends State<_AddGroupMemberSheet> {
  final _phone = TextEditingController();
  String _error = '';
  bool _saving = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = _phone.text.trim().replaceAll(' ', '');
    if (phone.length < 9) {
      setState(() => _error = 'Enter a valid phone number (at least 9 digits).');
      return;
    }
    setState(() {
      _saving = true;
      _error = '';
    });
    final ok = await groupWalletService.addMember(widget.groupWalletId, phone);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _saving = false;
        _error = 'That number is either already in the wallet, belongs to the owner, or is invalid.';
      });
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invited $phone to the group 📨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outline, width: 3),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.ink, size: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add member',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          const Text(
            'They will get an invitation they can accept or reject.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            decoration: const InputDecoration(
              labelText: 'Member phone number',
              hintText: 'e.g. 024 123 4567',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
          ],
          const SizedBox(height: 20),
          StickerButton(
            onTap: _saving ? null : _save,
            color: AppTheme.primary,
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: _saving
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(AppTheme.ink),
                    ),
                  )
                : const Text(
                    'Invite member',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: attach a new bank card.
Future<void> showAddCardSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddCardSheet(),
  );
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _bank = TextEditingController();
  final _nick = TextEditingController();
  final _number = TextEditingController();
  final _balance = TextEditingController();
  String _color = 'mint';
  String _error = '';

  @override
  void dispose() {
    _bank.dispose();
    _nick.dispose();
    _number.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final number = _number.text.replaceAll(' ', '');
    final balance = double.tryParse(_balance.text.replaceAll(',', ''));

    if (_bank.text.trim().isEmpty || number.length < 8) {
      setState(() => _error = 'Add the bank name and a valid card number.');
      return;
    }
    if (balance == null || balance < 0) {
      setState(() => _error = 'Enter a valid balance.');
      return;
    }

    final bloc = context.read<WalletBloc>();
    await walletService.addCard(
      bankName: _bank.text.trim(),
      nickname: _nick.text.trim(),
      cardNumber: number,
      balance: balance,
      color: _color,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${bloc.cards.last.nickname} added 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.mint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.add_card_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add a bank card',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            const Text(
              'Track the balance of one of your cards. You can pull money from it into your wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bank,
              decoration: const InputDecoration(
                labelText: 'Bank name',
                hintText: 'e.g. GCB Bank',
                prefixIcon: Icon(Icons.account_balance_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nick,
              decoration: const InputDecoration(
                labelText: 'Card nickname (optional)',
                hintText: 'e.g. Salary card',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _number,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
              ],
              decoration: const InputDecoration(
                labelText: 'Card number',
                hintText: '0000 0000 0000 0000',
                prefixIcon: Icon(Icons.credit_card_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balance,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'Current balance',
                hintText: 'e.g. 2500.00',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Card colour',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: move money from a bank card into the wallet.
Future<void> showTransferSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _TransferSheet(),
  );
}

class _TransferSheet extends StatefulWidget {
  const _TransferSheet();

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final _amountCtrl = TextEditingController();
  String? _walletId;
  String? _cardId;
  String _error = '';
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<WalletBloc>();
    if (_walletId == null && bloc.wallets.isNotEmpty) {
      _walletId = bloc.activeWalletId;
    }
    if (_cardId == null && bloc.cards.isNotEmpty) {
      _cardId = bloc.cards.first.id;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bloc = context.read<WalletBloc>();
    if (_cardId == null) {
      setState(() => _error = 'Add a card first.');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount to pull in.');
      return;
    }
    setState(() => _saving = true);
    final ok = await walletService.transferFromCard(
      walletId: _walletId,
      cardId: _cardId!,
      amount: amount,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      setState(() => _error = 'That card doesn\'t have enough balance.');
      return;
    }
    Navigator.of(context).pop();
    final wallet = bloc.walletById(_walletId ?? '') ?? bloc.activeWallet;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${Money.format(amount)} moved into ${wallet.name} 💸')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();
    final cards = bloc.cards;
    final wallet = bloc.walletById(_walletId ?? '') ?? bloc.activeWallet;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.compare_arrows_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pull money in',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'It leaves your card and splits into ${wallet.name} by your percentages.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _walletId,
              decoration: const InputDecoration(
                labelText: 'Into wallet',
                prefixIcon: Icon(Icons.savings_rounded),
              ),
              items: [
                for (final w in bloc.wallets)
                  DropdownMenuItem(
                    value: w.id,
                    child: Text('${w.name} • ${Money.format(w.totalBalance)}'),
                  ),
              ],
              onChanged: (v) => setState(() => _walletId = v),
            ),
            const SizedBox(height: 12),
            if (cards.isEmpty)
              Sticker(
                color: AppTheme.pink,
                padding: const EdgeInsets.all(18),
                child: const Column(
                  children: [
                    Text('No cards yet!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
                    SizedBox(height: 4),
                    Text('Add a bank card first so you can pull money into your wallet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _cardId,
                decoration: const InputDecoration(labelText: 'From card', prefixIcon: Icon(Icons.credit_card_rounded)),
                items: [
                  for (final c in cards)
                    DropdownMenuItem(value: c.id, child: Text('${c.nickname} • ${Money.format(c.balance)}')),
                ],
                onChanged: (v) => setState(() => _cardId = v),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 500',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            const SizedBox(height: 12),
            if (wallet.subWallets.isNotEmpty) ...[
              const Text(
                'How it will split',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 8),
              AllocationBar(wallet: wallet),
              const SizedBox(height: 4),
            ],
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _saving ? null : _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: _saving
                  ? const SizedBox(
                      width: 26, height: 26,
                      child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(AppTheme.ink)),
                    )
                  : const Text('Pull in', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: create a sub-wallet pocket with a percentage.
Future<void> showAddSubWalletSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddSubWalletSheet(),
  );
}

class _AddSubWalletSheet extends StatefulWidget {
  const _AddSubWalletSheet();

  @override
  State<_AddSubWalletSheet> createState() => _AddSubWalletSheetState();
}

class _AddSubWalletSheetState extends State<_AddSubWalletSheet> {
  final _title = TextEditingController();
  final _purpose = TextEditingController();
  final _percent = TextEditingController();
  final _allocation = TextEditingController();
  final _priority = TextEditingController();
  String _color = 'mint';
  String _error = '';

  @override
  void dispose() {
    _title.dispose();
    _purpose.dispose();
    _percent.dispose();
    _allocation.dispose();
    _priority.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bloc = context.read<WalletBloc>();
    final isFigures = bloc.activeWallet.splitMode == 'figures';

    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give it a title.');
      return;
    }

    if (isFigures) {
      final allocation = double.tryParse(_allocation.text);
      if (allocation == null || allocation <= 0) {
        setState(() => _error = 'Give it a title and an amount above 0.');
        return;
      }
      final priority = int.tryParse(_priority.text);
      if (priority == null || priority < 1) {
        setState(() => _error = 'Priority must be a number from 1 (highest) upwards.');
        return;
      }
      final ok = await walletService.addSubWallet(
        walletId: bloc.activeWalletId,
        title: _title.text.trim(),
        purpose: _purpose.text.trim(),
        percentage: 0,
        color: _color,
        allocation: allocation,
        priority: priority,
      );
      if (!mounted) return;
      if (!ok) {
        setState(() => _error = 'Could not create that pocket. Try a different priority.');
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_title.text.trim()} pocket created 🎉')),
      );
      return;
    }

    final percent = double.tryParse(_percent.text);
    if (percent == null || percent <= 0) {
      setState(() => _error = 'Give it a title and a percentage above 0%.');
      return;
    }
    final ok = await walletService.addSubWallet(
      walletId: bloc.activeWalletId,
      title: _title.text.trim(),
      purpose: _purpose.text.trim(),
      percentage: percent,
      color: _color,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = 'Only ${Money.percent(bloc.activeWallet.remainingPercent)} is left to allocate.');
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_title.text.trim()} pocket created 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();
    final isFigures = bloc.activeWallet.splitMode == 'figures';
    final nextPriority = bloc.activeWallet.subWallets.isNotEmpty
        ? bloc.activeWallet.subWallets
            .map((w) => w.priority)
            .reduce((a, b) => a > b ? a : b) + 1
        : 1;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.lavender,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.travel_explore_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'New pocket',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              isFigures
                  ? 'Each pocket gets a set amount, filled in priority order.'
                  : 'A pocket takes a fixed % of everything that lands in your wallet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Rent',
                prefixIcon: Icon(Icons.label_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purpose,
              decoration: const InputDecoration(
                labelText: 'Purpose (optional)',
                hintText: 'What is this for?',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 12),
            if (isFigures) ...[
              TextField(
                controller: _allocation,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 500',
                  prefixIcon: Icon(Icons.savings_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priority,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Priority',
                  hintText: '1 = filled first',
                  prefixIcon: const Icon(Icons.format_list_numbered_rounded),
                  suffixText: 'next free: $nextPriority',
                ),
              ),
            ] else
              TextField(
                controller: _percent,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: InputDecoration(
                  labelText: 'Percentage %',
                  hintText: 'e.g. 20',
                  suffixText: 'of ${Money.percent(bloc.activeWallet.remainingPercent)} free',
                  prefixIcon: const Icon(Icons.percent_rounded),
                ),
              ),
            const SizedBox(height: 18),
            const Text(
              'Pocket colour',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Text('Create pocket', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: edit an existing sub-wallet.
Future<void> showEditSubWalletSheet(BuildContext context, SubWallet subWallet) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditSubWalletSheet(subWallet: subWallet),
  );
}

class _EditSubWalletSheet extends StatefulWidget {
  final SubWallet subWallet;

  const _EditSubWalletSheet({required this.subWallet});

  @override
  State<_EditSubWalletSheet> createState() => _EditSubWalletSheetState();
}

class _EditSubWalletSheetState extends State<_EditSubWalletSheet> {
  late final TextEditingController _title;
  late final TextEditingController _purpose;
  late final TextEditingController _percent;
  late final TextEditingController _allocation;
  late final TextEditingController _priority;
  late String _color;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.subWallet.title);
    _purpose = TextEditingController(text: widget.subWallet.purpose);
    _percent = TextEditingController(
      text: widget.subWallet.percentage.toStringAsFixed(
        widget.subWallet.percentage == widget.subWallet.percentage.roundToDouble() ? 0 : 1,
      ),
    );
    final allocation = widget.subWallet.allocation;
    _allocation = TextEditingController(
      text: allocation != null
          ? allocation.toStringAsFixed(allocation == allocation.roundToDouble() ? 0 : 1)
          : '',
    );
    _priority = TextEditingController(text: widget.subWallet.priority.toString());
    _color = widget.subWallet.color;
  }

  @override
  void dispose() {
    _title.dispose();
    _purpose.dispose();
    _percent.dispose();
    _allocation.dispose();
    _priority.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bloc = context.read<WalletBloc>();
    final isFigures = bloc.activeWallet.splitMode == 'figures';

    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give it a title.');
      return;
    }

    if (isFigures) {
      final allocation = double.tryParse(_allocation.text);
      if (allocation == null || allocation <= 0) {
        setState(() => _error = 'Give it a title and an amount above 0.');
        return;
      }
      final priority = int.tryParse(_priority.text);
      if (priority == null || priority < 1) {
        setState(() => _error = 'Priority must be a number from 1 (highest) upwards.');
        return;
      }
      await walletService.updateSubWallet(
        walletId: bloc.activeWalletId,
        updated: widget.subWallet.copyWith(
          title: _title.text.trim(),
          purpose: _purpose.text.trim(),
          allocation: allocation,
          priority: priority,
          color: _color,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final percent = double.tryParse(_percent.text);
    if (percent == null || percent <= 0) {
      setState(() => _error = 'Give it a title and a percentage above 0%.');
      return;
    }
    final others = bloc.activeWallet.subWallets
        .where((w) => w.id != widget.subWallet.id)
        .fold(0.0, (s, w) => s + w.percentage);
    if (others + percent > 100) {
      setState(() => _error = 'Only ${Money.percent(100 - others)} is left to allocate.');
      return;
    }
    await walletService.updateSubWallet(
      walletId: bloc.activeWalletId,
      updated: widget.subWallet.copyWith(
        title: _title.text.trim(),
        purpose: _purpose.text.trim(),
        percentage: percent,
        color: _color,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isFigures = widget.subWallet.allocation != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.lavender,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.edit_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Edit pocket',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.label_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purpose,
              decoration: const InputDecoration(
                labelText: 'Purpose (optional)',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 12),
            if (isFigures) ...[
              TextField(
                controller: _allocation,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 500',
                  prefixIcon: Icon(Icons.savings_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priority,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  hintText: '1 = highest',
                  prefixIcon: Icon(Icons.format_list_numbered_rounded),
                  helperText: 'Changeable anytime — deposits fill lowest number first.',
                ),
              ),
            ] else
              TextField(
                controller: _percent,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Percentage %',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
              ),
            const SizedBox(height: 18),
            const Text(
              'Pocket colour',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Text('Save changes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: confirm removing something.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.pink,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outline, width: 3),
              ),
              child: const Icon(Icons.help_outline_rounded, color: AppTheme.ink, size: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (message != null) ...[
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 20),
          StickerButton(
            onTap: () => Navigator.of(context).pop(true),
            color: AppTheme.coral,
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              confirmLabel ?? 'Yes, remove it',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// Bottom sheet: withdraw from a pocket back to a card or to mobile money.
Future<void> showWithdrawSheet(
  BuildContext context, {
  String? walletId,
  String? subWalletId,
  required String title,
  required double available,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _WithdrawSheet(
      walletId: walletId,
      subWalletId: subWalletId,
      title: title,
      available: available,
    ),
  );
}

class _WithdrawSheet extends StatefulWidget {
  final String? walletId;
  final String? subWalletId;
  final String title;
  final double available;

  const _WithdrawSheet({
    required this.walletId,
    required this.subWalletId,
    required this.title,
    required this.available,
  });

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _amountCtrl = TextEditingController();
  String _destType = 'card';
  String? _cardId;
  String? _momoId;
  bool _showAddMoMo = false;
  String _error = '';
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<WalletBloc>();
    if (_cardId == null && bloc.cards.isNotEmpty) {
      _cardId = bloc.cards.first.id;
    }
    if (_momoId == null && bloc.momoWallets.isNotEmpty) {
      _momoId = bloc.momoWallets.first.id;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount to withdraw.');
      return;
    }
    if (amount > widget.available) {
      setState(() => _error = 'Only ${Money.format(widget.available)} is available here.');
      return;
    }
    if (_destType == 'card' && _cardId == null) {
      setState(() => _error = 'Add a bank card to withdraw back to.');
      return;
    }
    if (_destType == 'momo' && _momoId == null) {
      setState(() => _error = 'Add a mobile money wallet first.');
      return;
    }

    setState(() => _saving = true);
    final ok = await walletService.withdraw(
      walletId: widget.walletId,
      subWalletId: widget.subWalletId,
      destinationType: _destType,
      cardId: _destType == 'card' ? _cardId : null,
      momoId: _destType == 'momo' ? _momoId : null,
      amount: amount,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      setState(() => _error = 'Couldn\'t withdraw that amount.');
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${Money.format(amount)} withdrawn from ${widget.title} 🏦')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();

    if (_showAddMoMo) {
      return _InlineAddMoMo(
        onCancel: () => setState(() => _showAddMoMo = false),
        onSaved: (id) => setState(() {
          _momoId = id;
          _showAddMoMo = false;
        }),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.coral,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.north_east_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Withdraw from ${widget.title}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Available: ${Money.format(widget.available)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.inkSoft, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 100',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Withdraw to',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            _DestToggle(
              value: _destType,
              onChanged: (v) => setState(() => _destType = v),
            ),
            const SizedBox(height: 14),

            if (_destType == 'card') ...[
              if (bloc.cards.isEmpty)
                const _HintBox(
                  icon: Icons.add_card_rounded,
                  text: 'No bank cards yet. Add one in Accounts to withdraw back to it.',
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _cardId,
                  decoration: const InputDecoration(
                    labelText: 'Back to card',
                    prefixIcon: Icon(Icons.credit_card_rounded),
                  ),
                  items: [
                    for (final c in bloc.cards)
                      DropdownMenuItem(value: c.id, child: Text('${c.nickname} • ${Money.format(c.balance)}')),
                  ],
                  onChanged: (v) => setState(() => _cardId = v),
                ),
            ] else ...[
              if (bloc.momoWallets.isEmpty)
                const _HintBox(
                  icon: Icons.phone_iphone_rounded,
                  text: 'No mobile money wallets yet. Add one to withdraw into it.',
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _momoId,
                  decoration: const InputDecoration(
                    labelText: 'To mobile money',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                  items: [
                    for (final m in bloc.momoWallets)
                      DropdownMenuItem(value: m.id, child: Text('${m.provider} • ${m.number} (${m.name})')),
                  ],
                  onChanged: (v) => setState(() => _momoId = v),
                ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAddMoMo = true),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add mobile money'),
                ),
              ),
            ],

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _saving ? null : _save,
              color: AppTheme.coral,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: _saving
                  ? const SizedBox(
                      width: 26, height: 26,
                      child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(AppTheme.ink)),
                    )
                  : const Text('Withdraw', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented toggle between "Bank card" and "Mobile money".
class _DestToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _DestToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: AppTheme.surface,
      radius: 16,
      dy: 3,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _DestOption(
              icon: Icons.credit_card_rounded,
              label: 'Bank card',
              selected: value == 'card',
              onTap: () => onChanged('card'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _DestOption(
              icon: Icons.phone_iphone_rounded,
              label: 'Mobile money',
              selected: value == 'momo',
              onTap: () => onChanged('momo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DestOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.mint : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outline, width: 2.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.ink, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HintBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Sticker(
      color: AppTheme.pink,
      radius: 16,
      dy: 2,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.ink, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline mobile-money add form used inside the withdraw sheet.
class _InlineAddMoMo extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<String> onSaved;

  const _InlineAddMoMo({required this.onCancel, required this.onSaved});

  @override
  State<_InlineAddMoMo> createState() => _InlineAddMoMoState();
}

class _InlineAddMoMoState extends State<_InlineAddMoMo> {
  final _number = TextEditingController();
  String _provider = 'MTN';
  String _color = 'yellow';
  String _error = '';

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final number = _number.text.replaceAll(' ', '');
    if (number.length < 9) {
      setState(() => _error = 'Enter a valid mobile money number.');
      return;
    }
    final bloc = context.read<WalletBloc>();
    await walletService.addMoMo(
      provider: _provider,
      name: '$_provider line',
      number: number,
      color: _color,
    );
    if (!mounted) return;
    widget.onSaved(bloc.momoWallets.last.id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.sky,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.phone_iphone_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add mobile money',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            const Text(
              'Withdrawals can go straight to this number.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Provider',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              items: [
                for (final p in momoProviders)
                  DropdownMenuItem(value: p, child: Text(p)),
              ],
              onChanged: (v) => setState(() => _provider = v ?? 'MTN'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _number,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: const InputDecoration(
                labelText: 'Mobile money number',
                hintText: 'e.g. 024 123 4567',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Colour',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Text('Save', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(onPressed: widget.onCancel, child: const Text('Back')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: add a mobile money wallet (standalone, used in Accounts).
Future<void> showAddMoMoSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _StandaloneAddMoMo(),
  );
}

class _StandaloneAddMoMo extends StatefulWidget {
  @override
  State<_StandaloneAddMoMo> createState() => _StandaloneAddMoMoState();
}

class _StandaloneAddMoMoState extends State<_StandaloneAddMoMo> {
  final _number = TextEditingController();
  String _provider = 'MTN';
  String _color = 'yellow';
  String _error = '';

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final number = _number.text.replaceAll(' ', '');
    if (number.length < 9) {
      setState(() => _error = 'Enter a valid mobile money number.');
      return;
    }
    await walletService.addMoMo(
      provider: _provider,
      name: '$_provider line',
      number: number,
      color: _color,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.sky,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.phone_iphone_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add mobile money',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            const Text(
              'A number you can withdraw into from your pockets.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Provider',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              items: [
                for (final p in momoProviders)
                  DropdownMenuItem(value: p, child: Text(p)),
              ],
              onChanged: (v) => setState(() => _provider = v ?? 'MTN'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _number,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: const InputDecoration(
                labelText: 'Mobile money number',
                hintText: 'e.g. 024 123 4567',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Colour',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 10),
            ColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: const Text('Add mobile money', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: share one of the user's cards with another customer.
Future<void> showShareCardSheet(BuildContext context, BankCard card) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ShareCardSheet(card: card),
  );
}

class _ShareCardSheet extends StatefulWidget {
  final BankCard card;

  const _ShareCardSheet({required this.card});

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final _phone = TextEditingController();
  String _error = '';
  bool _saving = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = _phone.text.trim().replaceAll(' ', '');
    if (phone.length < 9) {
      setState(() => _error = 'Enter a valid phone number (at least 9 digits).');
      return;
    }
    setState(() {
      _saving = true;
      _error = '';
    });
    final pin = await showPinPrompt(
      context,
      title: 'Share ${widget.card.nickname}',
      subtitle: 'Enter your PIN to confirm sharing this card.',
      verify: (pin) => authService.verifyPin(pin),
    );
    if (pin == null) {
      if (mounted) setState(() => _saving = false);
      return;
    }
    if (!mounted) return;
    await cardShareService.shareCard(
      cardId: widget.card.id,
      cardName: widget.card.nickname,
      cardBankName: widget.card.bankName,
      cardLast4: widget.card.last4,
      cardColor: widget.card.color,
      inviteePhone: phone,
      pin: pin,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$phone can now accept access to ${widget.card.nickname} 📨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: themeColor(widget.card.color),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.share_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share ${widget.card.nickname}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.card.bankName} • ${widget.card.maskedNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'The other customer can accept access and request withdrawals (approved by you with your PIN).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: const InputDecoration(
                labelText: 'Customer phone number',
                hintText: 'e.g. 024 123 4567',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _saving ? null : _save,
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: _saving
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(AppTheme.ink),
                      ),
                    )
                  : const Text('Share card', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: withdraw money from a card into the wallet.
///
/// For an owned card ([shared] = false) the PIN confirms directly. For a
/// shared card ([shared] = true) a request is sent to the owner for approval.
Future<void> showCardWithdrawSheet(
  BuildContext context, {
  required BankCard card,
  required bool shared,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CardWithdrawSheet(card: card, shared: shared),
  );
}

class _CardWithdrawSheet extends StatefulWidget {
  final BankCard card;
  final bool shared;

  const _CardWithdrawSheet({required this.card, required this.shared});

  @override
  State<_CardWithdrawSheet> createState() => _CardWithdrawSheetState();
}

class _CardWithdrawSheetState extends State<_CardWithdrawSheet> {
  final _amountCtrl = TextEditingController();
  String _error = '';
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount to withdraw.');
      return;
    }
    if (amount > widget.card.balance) {
      setState(() => _error = 'Only ${Money.format(widget.card.balance)} is available on this card.');
      return;
    }

    setState(() => _saving = true);
    if (!widget.shared) {
      final pin = await showPinPrompt(
        context,
        title: 'Withdraw to wallet',
        subtitle: '${Money.format(amount)} from ${widget.card.nickname}',
        verify: (pin) => authService.verifyPin(pin),
      );
      if (pin == null) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      final ok = await walletService.withdrawFromCard(
        cardId: widget.card.id,
        amount: amount,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (!ok) {
        setState(() => _error = "Couldn't withdraw that amount.");
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Money.format(amount)} moved into your wallet 💰')),
      );
      return;
    }

    // Shared card: create a request for the owner to approve.
    await cardShareService.requestWithdrawal(
      cardId: widget.card.id,
      cardName: widget.card.nickname,
      cardBankName: widget.card.bankName,
      cardLast4: widget.card.last4,
      ownerPhone: _ownerPhone(),
      amount: amount,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdrawal request sent! The card owner will approve it shortly.')),
    );
  }

  String _ownerPhone() {
    final bloc = context.read<WalletBloc>();
    for (final share in bloc.acceptedSharesWithMe) {
      if (share.cardId == widget.card.id) return share.ownerPhone;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.coral,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.north_east_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Withdraw from ${widget.card.nickname}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              widget.shared
                  ? 'Available: ${Money.format(widget.card.balance)} · needs the owner\'s approval'
                  : 'Available: ${Money.format(widget.card.balance)} · goes straight to your wallet',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 100',
                prefixIcon: Icon(Icons.payments_rounded),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 20),
            StickerButton(
              onTap: _saving ? null : _save,
              color: widget.shared ? AppTheme.periwinkle : AppTheme.coral,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: _saving
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(AppTheme.ink),
                      ),
                    )
                  : Text(
                      widget.shared ? 'Request withdrawal' : 'Withdraw',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
