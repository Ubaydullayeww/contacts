import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../contacts_model/contact.dart';
import 'contact.dart';

class DetailPage extends StatefulWidget {
  final int contactId;

  const DetailPage({super.key, required this.contactId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _categoryController;
  late String _imageUrl;
  late bool _isImportant;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final contact = context.read<ContactsProvider>().getContactById(widget.contactId);
    if (contact != null) {
      _nameController = TextEditingController(text: contact.name);
      _numberController = TextEditingController(text: contact.number.toString());
      _categoryController = TextEditingController(text: contact.category);
      _imageUrl = contact.image;
      _isImportant = contact.isImportant;
    } else {
      _nameController = TextEditingController();
      _numberController = TextEditingController();
      _categoryController = TextEditingController();
      _imageUrl = 'https://via.placeholder.com/150';
      _isImportant = false;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _imageUrl = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm tanlashda xatolik yuz berdi: $e')),
      );
    }
  }

  void _updateContact() {
    if (_formKey.currentState!.validate()) {
      final contact = Contacts(
        id: widget.contactId,
        number: int.parse(_numberController.text),
        name: _nameController.text,
        image: _imageUrl,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        isImportant: _isImportant,
      );

      context.read<ContactsProvider>().updateContact(contact);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahrirlash'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : NetworkImage(_imageUrl) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ism',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, ismni kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Telefon raqami',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Iltimos, telefon raqamini kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategoriya (ixtiyoriy)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Muhim kontakt'),
              value: _isImportant,
              onChanged: (value) {
                setState(() {
                  _isImportant = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }
}