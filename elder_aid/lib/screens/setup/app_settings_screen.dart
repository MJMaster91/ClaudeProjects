import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import 'change_pin_screen.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (mounted) _nameController.text = name;
  }

  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    ref.invalidate(userNameProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name saved')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _goHome() => Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _goHome,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 36, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      const Text(
                        "User's Name",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Shown as a greeting on the home screen',
                    style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 20),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Margaret',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveName,
                      child: const Text('Save',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline,
                  size: 36, color: AppTheme.primary),
              title: const Text('Change PIN',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: const Text('Update your 4-digit setup PIN',
                  style: TextStyle(fontSize: 16)),
              trailing: const Icon(Icons.chevron_right),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePinScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
