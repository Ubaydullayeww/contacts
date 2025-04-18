import 'package:flutter/material.dart';
import '../contacts_model/contact.dart';
import 'contact.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({Key? key}) : super(key: key);

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final String _defaultImageUrl = "https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=2960&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: const Text('Yangi kontakt qo\'shish'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(_defaultImageUrl),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 30),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ism',
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
            child: TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon raqami',
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: _addNewContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Qo\'shish'),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewContact() {
    // Validate input
    if (_nameController.text.isEmpty || _numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, barcha maydonlarni to\'ldiring')),
      );
      return;
    }

    final contactsProvider = ContactsInherited.of(context);

    // Create new contact object
    final newContact = Contacts(
      id: 0, // ID will be generated in provider
      name: _nameController.text,
      number: int.tryParse(_numberController.text) ?? 0,
      image: _defaultImageUrl,
    );

    // Add contact in provider
    contactsProvider.addContact(newContact);

    // Navigate back
    Navigator.pop(context);
  }
}
