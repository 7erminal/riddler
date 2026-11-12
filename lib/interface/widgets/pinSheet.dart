import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Asks the user for their PIN and verifies it via [verify].
///
/// Returns the confirmed PIN on success, or `null` if cancelled.
Future<String?> showPinPrompt(
  BuildContext context, {
  required String title,
  String subtitle = 'Enter your PIN to confirm.',
  required Future<bool> Function(String pin) verify,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PinPromptSheet(
      title: title,
      subtitle: subtitle,
      verify: verify,
    ),
  );
}

class _PinPromptSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<bool> Function(String pin) verify;

  const _PinPromptSheet({
    required this.title,
    required this.subtitle,
    required this.verify,
  });

  @override
  State<_PinPromptSheet> createState() => _PinPromptSheetState();
}

class _PinPromptSheetState extends State<_PinPromptSheet> {
  static const _pinLength = 4;
  String _pin = '';
  String _error = '';
  bool _busy = false;

  void _onKey(String key) {
    if (_busy) return;
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += key;
      _error = '';
    });
    if (_pin.length == _pinLength) _verify();
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    final ok = await widget.verify(_pin);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(_pin);
      return;
    }
    setState(() {
      _busy = false;
      _error = 'Wrong PIN. Try again.';
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              child: const Icon(Icons.lock_rounded, color: AppTheme.ink, size: 26),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
          ),
          const SizedBox(height: 22),
          PinDots(length: _pin.length, total: _pinLength),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.error),
            ),
          ],
          const SizedBox(height: 24),
          PinPad(onTap: _onKey, onBackspace: _onBackspace),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
