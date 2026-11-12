import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ridlers/index.dart';

/// Plan a bill split between several people.
///
/// Still in early development: this only records who owes what after an
/// equal split. Moving money between the people comes later.
class SplitPaymentScreen extends StatefulWidget {
  const SplitPaymentScreen({super.key});

  @override
  State<SplitPaymentScreen> createState() => _SplitPaymentScreenState();
}

class _SplitPaymentScreenState extends State<SplitPaymentScreen> {
  final _titleCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final List<TextEditingController> _nameCtrls = [TextEditingController(), TextEditingController()];
  int _peopleCount = 2;
  String _error = '';
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _totalCtrl.dispose();
    for (final c in _nameCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _setPeopleCount(int count) {
    while (_nameCtrls.length < count) {
      _nameCtrls.add(TextEditingController());
    }
    while (_nameCtrls.length > count) {
      _nameCtrls.removeLast().dispose();
    }
    setState(() => _peopleCount = count);
  }

  Future<void> _create() async {
    final total = double.tryParse(_totalCtrl.text);
    if (total == null || total <= 0) {
      setState(() => _error = 'Enter the total amount of the bill.');
      return;
    }
    final names = [for (final c in _nameCtrls) c.text.trim()];
    if (names.any((n) => n.isEmpty)) {
      setState(() => _error = 'Give every person a name.');
      return;
    }

    setState(() => _busy = true);
    final split = await walletService.createSplit(
      title: _titleCtrl.text.trim().isEmpty ? 'Bill' : _titleCtrl.text.trim(),
      total: total,
      names: names,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    _titleCtrl.clear();
    _totalCtrl.clear();
    for (final c in _nameCtrls) {
      c.clear();
    }

    await showServiceSuccessSheet(
      context,
      title: 'Split created!',
      message: '${split.people.length} people, ${Money.format(split.sharePerPerson)} each.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<WalletBloc>();
    final share = double.tryParse(_totalCtrl.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const ServiceHeader(
                title: 'Split payment',
                subtitle: 'Divide a bill between friends. Each person gets an equal share for now.',
                icon: Icons.call_split_rounded,
                color: AppTheme.periwinkle,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bill name',
                  hintText: 'e.g. Sunday dinner',
                  prefixIcon: Icon(Icons.receipt_long_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _totalCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: const InputDecoration(
                  labelText: 'Total amount',
                  hintText: 'e.g. 300',
                  prefixIcon: Icon(Icons.payments_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'People',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.inkSoft),
                  ),
                  const Spacer(),
                  StickerButton(
                    onTap: _peopleCount > 2 ? () => _setPeopleCount(_peopleCount - 1) : null,
                    color: AppTheme.surface,
                    radius: 14,
                    dy: 2,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.remove_rounded, color: AppTheme.ink, size: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$_peopleCount',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.ink),
                    ),
                  ),
                  StickerButton(
                    onTap: _peopleCount < 10 ? () => _setPeopleCount(_peopleCount + 1) : null,
                    color: AppTheme.surface,
                    radius: 14,
                    dy: 2,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.add_rounded, color: AppTheme.ink, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < _peopleCount; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _nameCtrls[i],
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Person ${i + 1}',
                      hintText: 'e.g. Abena',
                      prefixIcon: const Icon(Icons.person_rounded),
                      suffixIcon: i >= 2
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => _setPeopleCount(_peopleCount - 1),
                            )
                          : null,
                    ),
                  ),
                ),
              if (share > 0) ...[
                const SizedBox(height: 6),
                Sticker(
                  color: AppTheme.lemon,
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: AppTheme.ink, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Each of $_peopleCount people pays ${Money.format(share / _peopleCount)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 14),
                ErrorBanner(message: _error),
              ],
              const SizedBox(height: 24),
              StickerButton(
                onTap: _busy ? null : _create,
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
                        'Create split',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink),
                      ),
              ),
              if (bloc.splitPayments.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Past splits', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final split in bloc.splitPayments.take(5))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Sticker(
                      color: AppTheme.surface,
                      radius: 18,
                      dy: 3,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.call_split_rounded, color: AppTheme.ink, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  split.title,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${split.people.length} people • ${Money.format(split.sharePerPerson)} each',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Money.format(split.total),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ink),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
