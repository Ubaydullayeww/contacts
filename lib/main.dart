import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/screen/contact.dart';
import 'model/screen/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContactsProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Contacts App',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          useMaterial3: true,
        ),
        home: const Home(),
      ),
    );
  }
}