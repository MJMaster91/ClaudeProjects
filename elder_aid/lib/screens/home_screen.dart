import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/contact_tile.dart';
import '../widgets/clock_header.dart';
import '../providers/contacts_provider.dart';
import '../providers/settings_provider.dart';
import 'messages_screen.dart';
import 'setup/setup_gate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final name = ref.watch(userNameProvider).valueOrNull ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ClockHeader(
                time: _formatTime(_now),
                date: _formatDate(_now),
                greeting: _buildGreeting(name, _now.hour),
              ),
              Expanded(
                child: contactsAsync.when(
                  data: (contacts) => contacts.isEmpty
                      ? const _EmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: contacts.length + 1,
                          itemBuilder: (ctx, i) => i < contacts.length
                              ? ContactTile(contact: contacts[i])
                              : _HelpTile(context: ctx),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => const Center(
                    child: Text('Could not load contacts',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNav(
          onMessages: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessagesScreen()),
          ),
          onSetup: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SetupGate()),
          ),
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
          'No contacts yet.\nAsk a family member to add some in Setup.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Color(0xFF6B6B6B)),
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final BuildContext context;
  const _HelpTile({required this.context});

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Need Help?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: const Text(
          'Tap a contact\'s photo to call them.\n\nTap Messages to send a text.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _showHelpDialog,
        child: Container(
          color: const Color(0xFFE8A838),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 72, color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Help',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final VoidCallback onMessages;
  final VoidCallback onSetup;
  const _BottomNav({required this.onMessages, required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      color: const Color(0xFF4A9B8E),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.message_outlined,
            label: 'Messages',
            onTap: onMessages,
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Setup',
            onTap: onSetup,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon, required this.label, required this.onTap});

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
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
