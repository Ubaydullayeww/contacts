
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../contacts_model/contact.dart';

class ContactsProvider extends ChangeNotifier {
  List<Contacts> _allContacts = [];
  List<Contacts> _filteredContacts = [];
  bool _isLoading = true;

  List<Contacts> get allContacts => _allContacts;
  List<Contacts> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/contacts.json');
      var jsonData = jsonDecode(response);

      List<Contacts> loadedContacts = [];
      for (var i in jsonData) {
        Contacts contact = Contacts(
          id: i['id'],
          number: i['number'],
          name: i['name'],
          image: i['image'],
        );
        loadedContacts.add(contact);
      }

      _allContacts = loadedContacts;
      _filteredContacts = loadedContacts;
    } catch (e) {
      print('Error loading contacts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterContacts(String query) {
    _filteredContacts = _allContacts
        .where((contact) => contact.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void addContact(Contacts newContact) {
    // Generate new ID based on the highest existing ID
    int newId = 1;
    if (_allContacts.isNotEmpty) {
      newId = _allContacts.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    }

    final contact = Contacts(
      id: newId,
      number: newContact.number,
      name: newContact.name,
      image: newContact.image,
    );

    _allContacts.add(contact);
    _filteredContacts = List.from(_allContacts);
    notifyListeners();
  }

  void updateContact(Contacts updatedContact) {
    final index = _allContacts.indexWhere((contact) => contact.id == updatedContact.id);

    if (index != -1) {
      _allContacts[index] = updatedContact;
      _filteredContacts = List.from(_allContacts);
      notifyListeners();
    }
  }

  void deleteContact(int id) {
    _allContacts.removeWhere((contact) => contact.id == id);
    _filteredContacts = List.from(_allContacts);
    notifyListeners();
  }

  Contacts? getContactById(int id) {
    try {
      return _allContacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }
}



class ContactsInherited extends InheritedNotifier<ContactsProvider> {
  const ContactsInherited({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ContactsProvider of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ContactsInherited>();
    return widget!.notifier!;
  }
}
