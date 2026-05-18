import 'package:flutter/material.dart';

class ClockHeader extends StatelessWidget {
  final String time;
  final String date;
  final String? greeting;
  final IconData icon;

  const ClockHeader({
    super.key,
    required this.time,
    required this.date,
    this.greeting,
    this.icon = Icons.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF4A9B8E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(
                        fontSize: 20, color: Color(0xFF6B6B6B)),
                  ),
                  if (greeting != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      greeting!,
                      style: const TextStyle(
                          fontSize: 20, color: Color(0xFF6B6B6B)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
