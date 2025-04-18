import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../contacts_model/contact.dart';
import 'contact.dart';
import 'package:flutter/material.dart';
import '../contacts_model/contact.dart';
import 'contact.dart';
import 'package:flutter/material.dart';
import '../contacts_model/contact.dart';
import 'contact.dart';
import 'package:flutter/material.dart';
import '../contacts_model/contact.dart';
import 'contact.dart';

class DetailPage extends StatefulWidget {
  final int contactId;

  const DetailPage({Key? key, required this.contactId}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailState();
}

class _DetailState extends State<DetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late String _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Controllerlarni boshlang'ich qiymat bilan ishga tushiramiz
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _imageUrl = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadContactDetails();
    }
  }

  void _loadContactDetails() {
    final provider = ContactsInherited.of(context);
    final contact = provider.getContactById(widget.contactId);

    if (contact != null) {
      // Controllerlarni yangi qiymatlar bilan yangilaymiz
      _nameController.text = contact.name;
      _numberController.text = contact.number.toString();
      _imageUrl = contact.image;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        title: const Text('Kontaktni tahrirlash'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(_imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Saqlash'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    final provider = ContactsInherited.of(context);

    final updatedContact = Contacts(
      id: widget.contactId,
      name: _nameController.text,
      number: int.tryParse(_numberController.text) ?? 0,
      image: _imageUrl,
    );

    provider.updateContact(updatedContact);
    Navigator.pop(context);
  }
}