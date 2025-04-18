import 'package:flutter/cupertino.dart';

import 'app.dart';
import 'model/screen/contact.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    ContactsInherited(
      notifier: ContactsProvider(),
      child: MyApp(),
    ),
  );
}