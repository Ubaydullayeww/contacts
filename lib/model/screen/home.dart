import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts/model/screen/detail.dart';
import 'package:contacts/model/screen/add_contact.dart';
import 'package:contacts/model/screen/phone.dart';

import 'contact.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ContactsInherited.of(context).loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsProvider = ContactsInherited.of(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contact'),
        backgroundColor: Colors.blueGrey,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
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
            return const Center(
              child: Text(
                'Kontaktlar topilmadi',
                style: TextStyle(fontSize: 18),
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
                    // Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(contact.image),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Text('${contact.number}'),
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
        backgroundColor: Colors.blueGrey,
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