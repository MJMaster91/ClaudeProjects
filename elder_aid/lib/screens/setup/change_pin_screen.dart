import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

enum _Step { current, newPin, confirm }

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  _Step _step = _Step.current;
  String _entered = '';
  String _newPin = '';
  String? _error;

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
    final prefs = await SharedPreferences.getInstance();

    if (_step == _Step.current) {
      final saved = prefs.getString('setup_pin') ?? '';
      if (_entered == saved) {
        setState(() {
          _step = _Step.newPin;
          _entered = '';
        });
      } else {
        setState(() {
          _entered = '';
          _error = 'Incorrect PIN. Try again.';
        });
      }
    } else if (_step == _Step.newPin) {
      setState(() {
        _newPin = _entered;
        _entered = '';
        _step = _Step.confirm;
      });
    } else {
      if (_entered == _newPin) {
        await prefs.setString('setup_pin', _newPin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PIN updated')),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _entered = '';
          _newPin = '';
          _step = _Step.newPin;
          _error = 'PINs did not match. Please try again.';
        });
      }
    }
  }

  String get _title {
    if (_step == _Step.current) return 'Enter current PIN';
    if (_step == _Step.newPin) return 'Enter new PIN';
    return 'Confirm new PIN';
  }

  void _goHome() => Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _goHome,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(_title,
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
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
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
    );
  }
}
