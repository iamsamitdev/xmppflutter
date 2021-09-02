import 'package:flutter/material.dart';
// import 'package:xmppflutter/pages/login_page.dart';
import 'package:xmppflutter/firebasemessage/notification_service.dart';
import 'package:xmppflutter/pages/screen_a.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    // เรียกใช้งานตัว Firebase Notification Service ที่สร้างไว้
    NotificationService.instance.start();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XMPP Flutter',
      // initialRoute: 'login',
      initialRoute: 'screen_a',
      // routes: {
      //   'login' : ( BuildContext context ) => LoginPage()
      // },
      routes: {
        'screen_a' : ( BuildContext context ) => ScreenA()
      },
    );
  }
}