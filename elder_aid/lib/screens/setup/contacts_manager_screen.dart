import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../db/database_helper.dart';
import '../../models/contact.dart';
import '../../theme/app_theme.dart';
import '../../providers/contacts_provider.dart';
import 'contact_edit_screen.dart';

class ContactsManagerScreen extends ConsumerWidget {
  const ContactsManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              ProviderScope.containerOf(context).invalidate(contactsProvider);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
      body: contactsAsync.when(
        data: (contacts) => contacts.isEmpty
            ? const Center(
                child: Text('No contacts yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18)))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: contacts.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (ctx, i) =>
                    _ContactRow(contact: contacts[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Error loading contacts')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact',
            style: TextStyle(fontSize: 18)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ContactEditScreen()),
          );
          ref.invalidate(contactsProvider);
        },
      ),
    );
  }
}

class _ContactRow extends ConsumerWidget {
  final Contact contact;
  const _ContactRow({required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _Avatar(contact),
      title: Text(contact.name,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold)),
      subtitle: Text(contact.phone,
          style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primary),
            iconSize: 28,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ContactEditScreen(contact: contact)),
              );
              ref.invalidate(contactsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            iconSize: 28,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Delete contact?',
                      style: TextStyle(fontSize: 22)),
                  content: Text('Remove ${contact.name}?',
                      style: const TextStyle(fontSize: 18)),
                  actions: [
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 18))),
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await DatabaseHelper().deleteContact(contact.id!);
                ref.invalidate(contactsProvider);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Contact contact;
  const _Avatar(this.contact);

  @override
  Widget build(BuildContext context) {
    if (contact.photoPath != null) {
      if (contact.photoPath!.startsWith('http')) {
        return CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(contact.photoPath!));
      }
      final file = File(contact.photoPath!);
      if (file.existsSync()) {
        return CircleAvatar(
            radius: 28, backgroundImage: FileImage(file));
      }
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppTheme.primary,
      child: Text(
        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
        style:
            const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
