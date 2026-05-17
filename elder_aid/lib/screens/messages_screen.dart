import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../providers/contacts_provider.dart';
import '../providers/whatsapp_provider.dart';
import '../widgets/whatsapp_tile.dart';
import '../theme/app_theme.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with WidgetsBindingObserver {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted =
        await NotificationListenerService.isPermissionGranted();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) =>
          Navigator.of(context).popUntil((r) => r.isFirst),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_permissionGranted) {
      return _NotificationAccessView(onGranted: _checkPermission);
    }

    final contactsAsync = ref.watch(contactsProvider);
    return contactsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Text('Could not load contacts',
            style: TextStyle(fontSize: 18)),
      ),
      data: (contacts) {
        final waContacts =
            contacts.where((c) => c.hasWhatsapp).toList();
        if (waContacts.isEmpty) {
          return const _EmptyState();
        }
        ref.watch(unreadWhatsappProvider);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: waContacts.length,
          itemBuilder: (_, i) => WhatsappTile(
            contact: waContacts[i],
            key: ValueKey(waContacts[i].id),
          ),
        );
      },
    );
  }
}

class _NotificationAccessView extends StatelessWidget {
  final VoidCallback onGranted;
  const _NotificationAccessView({required this.onGranted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active,
                size: 80, color: AppTheme.primary),
            const SizedBox(height: 24),
            const Text(
              'Allow message notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'So ElderAid can show you when new WhatsApp messages arrive, '
              'please allow notification access.',
              style: TextStyle(fontSize: 20, color: Color(0xFF6B6B6B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                onPressed: () async {
                  const ch = MethodChannel('com.elderaid/settings');
                  await ch.invokeMethod('openNotificationListenerSettings');
                },
                icon: const Icon(Icons.check, size: 28),
                label: const Text('Allow',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You only need to do this once.',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No WhatsApp contacts yet.\nAsk a family member to add contacts in Setup and enable WhatsApp for them.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Color(0xFF6B6B6B)),
        ),
      ),
    );
  }
}
