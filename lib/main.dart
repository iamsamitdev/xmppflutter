import 'package:flutter/material.dart';
import 'package:xmppflutter/pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XMPP Flutter',
      initialRoute: 'login',
      routes: {
        'login' : ( BuildContext context ) => LoginPage()
      },
    );
  }
}