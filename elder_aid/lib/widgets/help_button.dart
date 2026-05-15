import 'package:flutter/material.dart';

class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showHelpDialog(context),
      backgroundColor: const Color(0xFFE8A838),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.help_outline, size: 28),
      label: const Text('Help',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Need Help?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: const Text(
          'Tap a contact\'s photo or the Call button to call them.\n\nTap Messages to send a text.',
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
}
