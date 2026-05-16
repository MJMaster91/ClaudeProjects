import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../db/database_helper.dart';
import '../../models/contact.dart';
import '../../theme/app_theme.dart';

class ContactEditScreen extends StatefulWidget {
  final Contact? contact;
  const ContactEditScreen({super.key, this.contact});

  @override
  State<ContactEditScreen> createState() => _ContactEditScreenState();
}

class _ContactEditScreenState extends State<ContactEditScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _photoPath;
  final _picker = ImagePicker();

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.contact!.name;
      _phoneCtrl.text = widget.contact!.phone;
      _photoPath = widget.contact!.photoPath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final xfile = await _picker.pickImage(
        source: source, maxWidth: 800, imageQuality: 85);
    if (xfile != null) setState(() => _photoPath = xfile.path);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, size: 32,
                  color: AppTheme.primary),
              title: const Text('Camera',
                  style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, size: 32,
                  color: AppTheme.primary),
              title: const Text('Gallery',
                  style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Name and phone number are required.')));
      return;
    }
    final db = DatabaseHelper();
    if (_isEditing) {
      await db.updateContact(Contact(
        id: widget.contact!.id,
        name: name,
        phone: phone,
        photoPath: _photoPath,
        sortOrder: widget.contact!.sortOrder,
      ));
    } else {
      await db.insertContact(Contact(
          name: name, phone: phone, photoPath: _photoPath));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Contact' : 'New Contact'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showPhotoOptions,
              child: Stack(
                children: [
                  _PhotoPreview(photoPath: _photoPath),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(fontSize: 20),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, size: 28),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneCtrl,
              style: const TextStyle(fontSize: 20),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, size: 28),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 28),
                label: const Text('Save Contact',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String? photoPath;
  const _PhotoPreview({this.photoPath});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (photoPath != null) {
      if (photoPath!.startsWith('http')) {
        child = Image.network(photoPath!, fit: BoxFit.cover);
      } else {
        final file = File(photoPath!);
        child = file.existsSync()
            ? Image.file(file, fit: BoxFit.cover)
            : _placeholder();
      }
    } else {
      child = _placeholder();
    }
    return ClipOval(child: SizedBox(width: 120, height: 120, child: child));
  }

  Widget _placeholder() => Container(
        color: AppTheme.primary.withValues(alpha: 0.15),
        child: const Icon(Icons.person, size: 64, color: AppTheme.primary),
      );
}
