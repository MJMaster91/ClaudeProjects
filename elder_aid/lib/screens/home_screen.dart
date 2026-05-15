import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../models/contact.dart';
import '../widgets/contact_tile.dart';
import '../widgets/help_button.dart';
import 'messages_screen.dart';
import 'setup/setup_gate.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  return DatabaseHelper().getAllContacts();
});

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

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _ClockHeader(
                time: _formatTime(_now),
                date: _formatDate(_now),
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
                          itemCount: contacts.length,
                          itemBuilder: (_, i) =>
                              ContactTile(contact: contacts[i]),
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
        floatingActionButton: const HelpButton(),
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

class _ClockHeader extends StatelessWidget {
  final String time;
  final String date;
  const _ClockHeader({required this.time, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(fontSize: 20, color: Color(0xFF6B6B6B)),
          ),
        ],
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

class _BottomNav extends StatelessWidget {
  final VoidCallback onMessages;
  final VoidCallback onSetup;
  const _BottomNav({required this.onMessages, required this.onSetup});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFFDF6EC),
        border: Border(top: BorderSide(color: Color(0xFFE0D8CF))),
      ),
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
            Icon(icon, size: 28, color: const Color(0xFF4A9B8E)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF2C2C2C))),
          ],
        ),
      ),
    );
  }
}
