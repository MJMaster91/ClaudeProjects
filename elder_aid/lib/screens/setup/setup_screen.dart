import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/contacts_provider.dart';
import 'contacts_manager_screen.dart';
import 'app_settings_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with WidgetsBindingObserver {
  bool _notificationGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationAccess();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkNotificationAccess();
  }

  Future<void> _checkNotificationAccess() async {
    final granted =
        await NotificationListenerService.isPermissionGranted();
    if (mounted) setState(() => _notificationGranted = granted);
  }

  void _goHome() {
    ref.invalidate(contactsProvider);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
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
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SetupTile(
              icon: Icons.tune,
              title: 'App Settings',
              subtitle: 'Set name, change PIN',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AppSettingsScreen()),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            _SetupTile(
              icon: Icons.notifications_active,
              title: 'Notification Access',
              subtitle: _notificationGranted
                  ? 'Granted — WhatsApp badges are active'
                  : 'Not granted — tap to enable',
              trailing: _notificationGranted
                  ? const Icon(Icons.check_circle,
                      color: Color(0xFF25D366), size: 28)
                  : const Icon(Icons.chevron_right),
              onTap: () async {
                const ch = MethodChannel('com.elderaid/settings');
                await ch.invokeMethod('openNotificationListenerSettings');
              },
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
  final Widget? trailing;
  const _SetupTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.trailing});

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
        trailing: trailing ?? const Icon(Icons.chevron_right),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
      ),
    );
  }
}
