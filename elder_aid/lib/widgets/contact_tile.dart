import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../theme/app_theme.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  const ContactTile({super.key, required this.contact});

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _call,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Avatar(photoPath: contact.photoPath, name: contact.name),
              const SizedBox(height: 10),
              Text(
                contact.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.call, size: 20),
                  label: const Text('Call', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoPath;
  final String name;
  const _Avatar({this.photoPath, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      final file = File(photoPath!);
      if (file.existsSync()) {
        return CircleAvatar(radius: 40, backgroundImage: FileImage(file));
      }
    }
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppTheme.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 32, color: Colors.white),
      ),
    );
  }
}
