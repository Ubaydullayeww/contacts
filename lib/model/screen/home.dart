import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:contacts/model/screen/detail.dart';
import 'package:contacts/model/screen/add_contact.dart';
import 'package:contacts/model/screen/phone.dart';
import 'package:provider/provider.dart';

import 'contact.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContacts();
    });
  }

  Widget _buildContactImage(String imageUrl) {
    if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 30);
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 30);
        },
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final contactsProvider = context.read<ContactsProvider>();
    switch (index) {
      case 0: // Kontaktlar
        contactsProvider.setCategory(null);
        contactsProvider.toggleShowOnlyImportant(false);
        break;
      case 1: // Oxirgilar
        // TODO: Implement recent contacts
        break;
      case 2: // Saralanganlar
        contactsProvider.setCategory(null);
        contactsProvider.toggleShowOnlyImportant(true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsProvider = context.watch<ContactsProvider>();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contact'),
        backgroundColor: Colors.blueGrey,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: contactsProvider.filterContacts,
                  decoration: InputDecoration(
                    hintText: "Qidirish...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Consumer<ContactsProvider>(
                builder: (context, provider, child) {
                  final categories = provider.categories;
                  if (categories.isEmpty) return const SizedBox.shrink();
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Barchasi'),
                          selected: provider.selectedCategory == null,
                          onSelected: (selected) {
                            provider.setCategory(null);
                          },
                        ),
                        ...categories.map((category) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FilterChip(
                            label: Text(category),
                            selected: provider.selectedCategory == category,
                            onSelected: (selected) {
                              provider.setCategory(category);
                            },
                          ),
                        )),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: contactsProvider,
        builder: (context, _) {
          if (contactsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = contactsProvider.filteredContacts;

          if (contacts.isEmpty) {
            return Center(
              child: Text(
                _selectedIndex == 2 
                    ? 'Saralangan kontaktlar yo\'q'
                    : 'Kontaktlar topilmadi',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: ClipOval(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: _buildContactImage(contact.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              if (contact.isImportant)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.star, color: Colors.amber, size: 16),
                                ),
                            ],
                          ),
                          Text('${contact.number}'),
                          if (contact.category != null)
                            Text(
                              contact.category!,
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (contex) {
                            return AlertDialog(
                              title: const Text('Realy?'),
                              content: const Text('Kontaktni o\'chirmoqchimisiz?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    contactsProvider.deleteContact(contact.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Ha'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yo\'q'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(CupertinoIcons.trash),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(contactId: contact.id),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.pen),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(contactId: contact.id),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.phone),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddContactPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2),
            label: 'Kontaktlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'Oxirgilar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            label: 'Saralanganlar',
          ),
        ],
      ),
    );
  }
}