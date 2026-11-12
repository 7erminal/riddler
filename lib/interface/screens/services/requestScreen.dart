import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Request money from another customer, or pay incoming requests.
///
/// A request creates a shareable link (locally `ridlers://pay/<id>`); the
/// link would be delivered over a backend later. Incoming requests show up
/// in this screen where they can be paid (card + PIN) or declined.
class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen> {
  final _numberCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _error = '';
  bool _busy = false;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _createRequest() async {
    final number = _numberCtrl.text.replaceAll(' ', '');
    final amount = double.tryParse(_amountCtrl.text);
    if (number.length < 9) {
      setState(() => _error = 'Enter the number of the person to ask.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount to request.');
      return;
    }

    setState(() => _busy = true);
    final request = await walletService.createMoneyRequest(
      payerNumber: number,
      amount: amount,
      note: _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);

    await _showLinkSheet(request);
    if (!mounted) return;
    _numberCtrl.clear();
    _amountCtrl.clear();
    _noteCtrl.clear();
    setState(() => _error = '');
  }

  Future<void> _showLinkSheet(MoneyRequest request) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.coral,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.outline, width: 3),
                ),
                child: const Icon(Icons.link_rounded, color: AppTheme.ink, size: 28),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Request sent!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '${Money.format(request.amount)} requested from ${request.payerNumber}.\nShare this link with them:',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
            ),
            const SizedBox(height: 16),
            Sticker(
              color: AppTheme.surface,
              radius: 16,
              dy: 2,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      request.link,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.ink),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppTheme.ink),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(ClipboardData(text: request.link));
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            StickerButton(
              onTap: () => Navigator.of(context).pop(),
              color: AppTheme.primary,
              radius: 20,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payRequest(MoneyRequest request) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PayRequestSheet(request: request),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Money.format(request.amount)} sent to ${request.requesterNumber}')),
      );
    }
  }

  Future<void> _declineRequest(MoneyRequest request) async {
    final ok = await confirmDelete(
      context,
      title: 'Decline request?',
      message: '${request.requesterNumber} asked for ${Money.format(request.amount)}. Declining tells them no.',
      confirmLabel: 'Decline',
    );
    if (!ok || !mounted) return;
    await walletService.declineMoneyRequest(request.id);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const ServiceHeader(
                title: 'Request money',
                subtitle: 'Ask another customer for money. A link is sent to them; they confirm with their PIN.',
                icon: Icons.request_page_rounded,
                color: AppTheme.coral,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _numberCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                  labelText: 'Who to ask',
                  hintText: 'e.g. 024 123 4567',
                  prefixIcon: Icon(Icons.person_search_rounded),
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              TextField(
                controller: _noteCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'What for? (optional)',
                  hintText: 'e.g. Dinner last night',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 14),
                ErrorBanner(message: _error),
              ],
              const SizedBox(height: 20),
              StickerButton(
                onTap: _busy ? null : _createRequest,
                color: AppTheme.primary,
                radius: 20,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: _busy
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(AppTheme.ink),
                        ),
                      )
                    : const Text(
                        'Send request',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
              ),
              const SizedBox(height: 28),
              Text('Incoming requests', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text(
                'Someone asked you for money. Pay with a card or decline.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
              ),
              const SizedBox(height: 12),
              if (bloc.pendingRequests.isEmpty)
                Sticker(
                  color: AppTheme.surface,
                  padding: const EdgeInsets.all(22),
                  child: const Column(
                    children: [
                      Icon(Icons.done_all_rounded, color: AppTheme.inkFaint, size: 34),
                      SizedBox(height: 8),
                      Text(
                        'No incoming requests right now.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
                      ),
                    ],
                  ),
                )
              else
                for (final request in bloc.pendingRequests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Sticker(
                      color: AppTheme.surface,
                      radius: 18,
                      dy: 3,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.coral,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.outline, width: 2.5),
                            ),
                            child: const Icon(Icons.request_page_rounded, color: AppTheme.ink, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.requesterName.isEmpty
                                      ? request.requesterNumber
                                      : '${request.requesterName} • ${request.requesterNumber}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink),
                                ),
                                if (request.note.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    request.note,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  Money.format(request.amount),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.error),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              StickerButton(
                                onTap: () => _payRequest(request),
                                color: AppTheme.mint,
                                radius: 12,
                                dy: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: const Text(
                                  'Pay',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => _declineRequest(request),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.inkFaint, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to authorise paying an incoming request.
class _PayRequestSheet extends StatefulWidget {
  final MoneyRequest request;

  const _PayRequestSheet({required this.request});

  @override
  State<_PayRequestSheet> createState() => _PayRequestSheetState();
}

class _PayRequestSheetState extends State<_PayRequestSheet> {
  String? _cardId;
  String _error = '';
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cardId == null) {
      final cards = context.read<WalletBloc>().cards;
      if (cards.isNotEmpty) _cardId = cards.first.id;
    }
  }

  Future<void> _confirm() async {
    if (_cardId == null) {
      setState(() => _error = 'Pick the card to pay with.');
      return;
    }
    final card = context.read<WalletBloc>().cardById(_cardId!);
    if (card == null) return;
    if (card.balance < widget.request.amount) {
      setState(() => _error = 'Only ${Money.format(card.balance)} is available on that card.');
      return;
    }

    final pin = await showPinPrompt(
      context,
      title: 'Pay ${widget.request.requesterNumber}',
      subtitle: '${Money.format(widget.request.amount)} leaves your card.',
      verify: (p) => authService.verifyPin(p),
    );
    if (pin == null || !mounted) return;

    setState(() => _busy = true);
    final ok = await walletService.payMoneyRequest(
      requestId: widget.request.id,
      cardId: _cardId!,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = 'Payment failed. Try again.');
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.coral,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outline, width: 3),
              ),
              child: const Icon(Icons.request_page_rounded, color: AppTheme.ink, size: 26),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${widget.request.requesterName.isEmpty ? 'A friend' : widget.request.requesterName} asked for ${Money.format(widget.request.amount)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            widget.request.requesterNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
          ),
          if (widget.request.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '"${widget.request.note}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Pay with',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
          ),
          const SizedBox(height: 8),
          CardSelector(
            cards: bloc.cards,
            selectedId: _cardId,
            onChanged: (id) => setState(() => _cardId = id),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: _error),
          ],
          const SizedBox(height: 20),
          StickerButton(
            onTap: _busy ? null : _confirm,
            color: AppTheme.primary,
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _busy
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(AppTheme.ink),
                    ),
                  )
                : const Text(
                    'Confirm & pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink),
                  ),
          ),
        ],
      ),
    );
  }
}
