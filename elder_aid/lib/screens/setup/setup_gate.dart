import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../providers/contacts_provider.dart';
import 'setup_screen.dart';

const _pinKey = 'setup_pin';

class SetupGate extends ConsumerStatefulWidget {
  const SetupGate({super.key});

  @override
  ConsumerState<SetupGate> createState() => _SetupGateState();
}

class _SetupGateState extends ConsumerState<SetupGate> {
  String? _savedPin;
  bool _loading = true;
  String _entered = '';
  String _firstPin = '';
  bool _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString(_pinKey);
      _loading = false;
    });
  }

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += d;
      _error = null;
    });
    if (_entered.length == 4) _onPinComplete();
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _onPinComplete() async {
    if (_savedPin == null) {
      if (!_confirming) {
        setState(() {
          _firstPin = _entered;
          _entered = '';
          _confirming = true;
        });
      } else {
        if (_entered == _firstPin) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_pinKey, _entered);
          if (mounted) _goToSetup();
        } else {
          setState(() {
            _entered = '';
            _firstPin = '';
            _confirming = false;
            _error = 'PINs did not match. Please try again.';
          });
        }
      }
    } else {
      if (_entered == _savedPin) {
        _goToSetup();
      } else {
        setState(() {
          _entered = '';
          _error = 'Incorrect PIN. Try again.';
        });
      }
    }
  }

  void _goToSetup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  }

  void _goHome() {
    ref.invalidate(contactsProvider);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCreating = _savedPin == null;
    final String title = isCreating
        ? (_confirming ? 'Confirm your PIN' : 'Create a 4-digit PIN')
        : 'Enter Setup PIN';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _goHome(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setup'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: _goHome,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppTheme.primary : Colors.transparent,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 16)),
              ],
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      for (final row in [
                        ['1', '2', '3'],
                        ['4', '5', '6'],
                        ['7', '8', '9'],
                        ['', '0', '⌫'],
                      ])
                        Expanded(
                          child: Row(
                            children: row.map((d) {
                              if (d.isEmpty) {
                                return const Expanded(child: SizedBox());
                              }
                              final isDelete = d == '⌫';
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDelete
                                          ? Colors.grey.shade200
                                          : AppTheme.primary,
                                      foregroundColor: isDelete
                                          ? AppTheme.textPrimary
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      elevation: isDelete ? 0 : 2,
                                    ),
                                    onPressed:
                                        isDelete ? _onDelete : () => _onDigit(d),
                                    child: Text(d,
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
