import 'package:flutter/material.dart';

class SetupGate extends StatelessWidget {
  const SetupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) =>
          Navigator.of(context).popUntil((r) => r.isFirst),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setup'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ),
        body: const Center(
          child: Text('Setup — coming soon',
              style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
