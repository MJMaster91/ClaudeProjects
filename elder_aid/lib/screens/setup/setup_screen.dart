import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/contacts_provider.dart';
import 'contacts_manager_screen.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  void _goHome(BuildContext context, WidgetRef ref) {
    ref.invalidate(contactsProvider);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _goHome(context, ref),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setup'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _goHome(context, ref),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SetupTile(
              icon: Icons.people,
              title: 'Contacts',
              subtitle: 'Add, edit or remove contacts',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ContactsManagerScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SetupTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 36, color: AppTheme.primary),
        title: Text(title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        subtitle:
            Text(subtitle, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
      ),
    );
  }
}
