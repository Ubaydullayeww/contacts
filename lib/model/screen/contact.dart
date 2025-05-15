import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../contacts_model/contact.dart';

class ContactsProvider extends ChangeNotifier {
  List<Contacts> _allContacts = [];
  List<Contacts> _filteredContacts = [];
  bool _isLoading = true;
  String? _selectedCategory;
  bool _showOnlyImportant = false;

  List<Contacts> get allContacts => _allContacts;
  List<Contacts> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;
  bool get showOnlyImportant => _showOnlyImportant;

  List<String> get categories {
    return _allContacts
        .map((contact) => contact.category)
        .where((category) => category != null)
        .toSet()
        .toList()
        .cast<String>();
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _allContacts = jsonList.map((json) => Contacts.fromJson(json)).toList();
        _filteredContacts = _allContacts;
      } else {
        // If no local file exists, load from assets
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
        await _saveContacts(); // Save to local storage
      }
    } catch (e) {
      print('Error loading contacts: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveContacts() async {
    try {
      final file = await _getLocalFile();
      final jsonList = _allContacts.map((contact) => contact.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving contacts: $e');
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/contacts.json');
  }

  void filterContacts(String query) {
    var filtered = _allContacts;
    
    if (query.isNotEmpty) {
      filtered = filtered.where((contact) => 
        contact.name.toLowerCase().contains(query.toLowerCase()) ||
        contact.number.toString().contains(query)
      ).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((contact) => 
        contact.category == _selectedCategory
      ).toList();
    }

    if (_showOnlyImportant) {
      filtered = filtered.where((contact) => 
        contact.isImportant
      ).toList();
    }

    _filteredContacts = filtered;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    filterContacts('');
  }

  void toggleShowOnlyImportant([bool? value]) {
    _showOnlyImportant = value ?? !_showOnlyImportant;
    filterContacts('');
  }

  void addContact(Contacts newContact) {
    int newId = 1;
    if (_allContacts.isNotEmpty) {
      newId = _allContacts.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    }

    final contact = Contacts(
      id: newId,
      number: newContact.number,
      name: newContact.name,
      image: newContact.image,
      category: newContact.category,
      isImportant: newContact.isImportant,
    );

    _allContacts.add(contact);
    _filteredContacts = List.from(_allContacts);
    _saveContacts();
    notifyListeners();
  }

  void updateContact(Contacts updatedContact) {
    final index = _allContacts.indexWhere((contact) => contact.id == updatedContact.id);

    if (index != -1) {
      _allContacts[index] = updatedContact;
      _filteredContacts = List.from(_allContacts);
      _saveContacts();
      notifyListeners();
    }
  }

  void deleteContact(int id) {
    _allContacts.removeWhere((contact) => contact.id == id);
    _filteredContacts = List.from(_allContacts);
    _saveContacts();
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
