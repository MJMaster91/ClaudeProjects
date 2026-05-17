import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../providers/whatsapp_provider.dart';

class WhatsappTile extends ConsumerWidget {
  final Contact contact;
  const WhatsappTile({super.key, required this.contact});

  String _e164(String phone) {
    final digits = phone.replaceAll(RegExp(r'[\s\-().]+'), '');
    return digits.startsWith('+') ? digits : '+$digits';
  }

  Future<void> _openWhatsapp(BuildContext context, WidgetRef ref) async {
    if (contact.id != null) {
      ref.read(unreadWhatsappProvider.notifier).clearUnread(contact.id!);
    }
    final uri = Uri.parse('whatsapp://send?phone=${_e164(contact.phone)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp is not installed on this device.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = contact.id != null
        ? (ref.watch(unreadWhatsappProvider)[contact.id!] ?? 0)
        : 0;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openWhatsapp(context, ref),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _FullPhoto(photoPath: contact.photoPath, name: contact.name),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FullPhoto extends StatelessWidget {
  final String? photoPath;
  final String name;
  const _FullPhoto({this.photoPath, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      if (photoPath!.startsWith('http')) {
        return Image.network(
          photoPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsBox(),
        );
      }
      final file = File(photoPath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return _initialsBox();
  }

  Widget _initialsBox() {
    return Container(
      color: const Color(0xFF25D366),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
