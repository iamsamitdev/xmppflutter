import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xmppflutter/firebasemessage/notification_bloc.dart';
import 'package:xmppflutter/pages/screen_b.dart';

class ScreenA extends StatefulWidget {
  @override
  _ScreenAState createState() => _ScreenAState();
}

class _ScreenAState extends State<ScreenA> {

  // เรียกใช้ Stream
  StreamSubscription<Map> _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _notificationSubscription = NotificationsBloc.instance.notificationStream.listen(_performActionOnNotification);
  }

  _performActionOnNotification(Map<String, dynamic> message) async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ScreenB())
    );
  }

  @override
  void dispose() {
    super.dispose();
    _notificationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen A'),
      ),
      body: Center(
        child: Text('Welcome to Screen A'),
      ),
    );
  }
}