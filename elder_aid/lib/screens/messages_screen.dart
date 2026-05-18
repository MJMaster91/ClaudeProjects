import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../providers/contacts_provider.dart';
import '../providers/whatsapp_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/whatsapp_tile.dart';
import '../widgets/clock_header.dart';
import '../theme/app_theme.dart';
import 'setup/setup_gate.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with WidgetsBindingObserver {
  bool _permissionGranted = false;
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationListenerService.isPermissionGranted();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  String? _buildGreeting(String name, int hour) {
    if (name.isEmpty) return null;
    final String prefix;
    if (hour >= 5 && hour < 12) {
      prefix = 'Good morning';
    } else if (hour >= 12 && hour < 18) {
      prefix = 'Good afternoon';
    } else if (hour >= 18) {
      prefix = 'Good evening';
    } else {
      prefix = 'Good night';
    }
    return '$prefix, $name!';
  }

  void _goHome() => Navigator.of(context).popUntil((r) => r.isFirst);

  void _goSetup() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetupGate()),
      );

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userNameProvider).valueOrNull ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _goHome(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ClockHeader(
                time: _formatTime(_now),
                date: _formatDate(_now),
                greeting: _buildGreeting(name, _now.hour),
                icon: Icons.message_outlined,
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          onPhone: _goHome,
          onSetup: _goSetup,
        ),
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
        child: Text('Could not load contacts', style: TextStyle(fontSize: 18)),
      ),
      data: (contacts) {
        final waContacts = contacts.where((c) => c.hasWhatsapp).toList();
        if (waContacts.isEmpty) return const _EmptyState();
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

class _BottomNav extends StatelessWidget {
  final VoidCallback onPhone;
  final VoidCallback onSetup;
  const _BottomNav({required this.onPhone, required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      color: const Color(0xFF4A9B8E),
      child: Row(
        children: [
          _NavItem(icon: Icons.phone_outlined, label: 'Contacts', onTap: onPhone),
          _NavItem(icon: Icons.settings_outlined, label: 'Setup', onTap: onSetup),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
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
