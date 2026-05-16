import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  void _goHome(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _goHome(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _goHome(context),
          ),
        ),
        body: const Center(
          child: Text('Messages — coming soon',
              style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
