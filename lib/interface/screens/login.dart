import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridlers/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = AppRoutes.login;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Mode { signIn, create }

class _LoginScreenState extends State<LoginScreen> {
  _Mode _mode = _Mode.signIn;
  int _step = 0; // 0 = phone, 1 = pin
  String _phone = '';
  String _name = '';
  String _pin = '';
  String _confirmPin = '';
  String _error = '';
  bool _busy = false;

  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  static const _pinLength = 4;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _resetToPhone() {
    setState(() {
      _step = 0;
      _pin = '';
      _confirmPin = '';
      _error = '';
    });
  }

  void _setMode(_Mode mode) {
    setState(() {
      _mode = mode;
      _resetToPhone();
    });
  }

  Future<void> _continueFromPhone() async {
    final phone = _phoneCtrl.text.replaceAll(' ', '');
    if (phone.isEmpty || phone.length < 9) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }
    _name = _nameCtrl.text.trim();
    setState(() {
      _phone = phone;
      _error = '';
      _step = 1;
      _pin = '';
      _confirmPin = '';
    });
  }

  Future<void> _onKey(String key) async {
    if (_busy) return;
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += key;
        _error = '';
      });
      if (_pin.length == _pinLength) {
        await _afterPinComplete();
      }
    }
  }

  Future<void> _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
    return Future.value();
  }

  Future<void> _afterPinComplete() async {
    if (_mode == _Mode.create) {
      if (_confirmPin.isEmpty) {
        setState(() {
          _confirmPin = _pin;
          _pin = '';
        });
        return;
      }
      if (_pin != _confirmPin) {
        setState(() {
          _error = 'PINs don\'t match. Try again.';
          _pin = '';
          _confirmPin = '';
        });
        return;
      }
    }

    setState(() => _busy = true);
    final error = _mode == _Mode.create
        ? await authService.createAccount(phone: _phone, pin: _pin, name: _name)
        : await authService.login(phone: _phone, pin: _pin);

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
        _pin = '';
        if (_mode == _Mode.create) _confirmPin = '';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.outline, width: 3),
                      ),
                      child: const Icon(
                        Icons.savings_rounded,
                        color: AppTheme.ink,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ridlers',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  _step == 0
                      ? (_mode == _Mode.create ? 'Create your account' : 'Welcome back!')
                      : (_mode == _Mode.create
                          ? _confirmPin.isEmpty
                              ? 'Choose your PIN'
                              : 'Confirm your PIN'
                          : 'Enter your PIN'),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _step == 0
                      ? 'Use your phone number so we know it\'s you.'
                      : 'Your 4-digit PIN keeps your wallet safe.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 26),

                if (_step == 0) _buildPhoneStep() else _buildPinStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Sticker(
          color: AppTheme.surface,
          radius: 22,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_mode == _Mode.create) ...[
                const _FieldLabel('Your name (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Abena',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const _FieldLabel('Phone number'),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                  hintText: '233 20 000 0000',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
            ],
          ),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: _error),
        ],
        const SizedBox(height: 24),
        StickerButton(
          onTap: _continueFromPhone,
          color: AppTheme.primary,
          radius: 20,
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: AppTheme.ink),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _mode == _Mode.signIn
                  ? 'New to Ridlers? '
                  : 'Already have an account? ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.inkSoft,
              ),
            ),
            GestureDetector(
              onTap: () => _setMode(
                _mode == _Mode.signIn ? _Mode.create : _Mode.signIn,
              ),
              child: const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Sticker(
          color: AppTheme.surface,
          radius: 22,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
          child: Column(
            children: [
              Text(
                _phone.replaceRange(0, _phone.length - 3, '•••  •••  •••'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 22),
              PinDots(length: _pin.length, total: _pinLength),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 18),
                _ErrorBanner(message: _error),
              ],
              const SizedBox(height: 26),
              PinPad(onTap: _onKey, onBackspace: _onBackspace),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _resetToPhone,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 18),
                SizedBox(width: 4),
                Text('Change phone number'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.inkSoft,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
