import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/screen/contact.dart';
import 'model/screen/home.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContactsInherited(
      notifier: ContactsProvider(),
      child: MaterialApp(
        title: 'Contacts App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.blueGrey.shade100,
        ),
        home: const Home(),
      ),
    );
  }
}
