import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../models/contact.dart';

final contactsProvider = FutureProvider<List<Contact>>((ref) async {
  return DatabaseHelper().getAllContacts();
});
