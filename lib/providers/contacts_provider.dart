import 'package:flutter/foundation.dart';
import '../db/db_helper.dart';
import '../models/contact.dart';

class ContactsProvider extends ChangeNotifier {
  List<Contact> _contacts = [];
  bool _loading = false;

  List<Contact> get contacts => List.unmodifiable(_contacts);
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _contacts = await DBHelper.getContacts();
    _loading = false;
    notifyListeners();
  }

  Future<void> addContact(String name, int avatarColor) async {
    final contact = Contact(
      name: name,
      avatarColor: avatarColor,
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await DBHelper.insertContact(contact);
    _contacts.insert(0, contact.copyWith(id: id));
    notifyListeners();
  }

  Future<void> deleteContact(int id) async {
    await DBHelper.deleteContact(id);
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Refresh contact list (e.g. after sending a message updates last preview).
  Future<void> refresh() => load();
}
