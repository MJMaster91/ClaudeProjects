import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) =>
          Navigator.of(context).popUntil((r) => r.isFirst),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
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
