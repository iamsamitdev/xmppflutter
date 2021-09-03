import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xmppflutter/utils/constant.dart';

class CallAPI {

  // กำหนด header ของ api
  _setHeaders() => {
    'Content-Type':'application/json',
    'Accept':'application/json'
  };

  // Register Device ที่ติดตั้งเข้ามา
  registerDevice(data) async {
    return await http.post(
      Uri.parse(baseAPIURL+'register_device.php'),
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

  // Sendnotification API
  sendFirebaseNoti(data) async {
    return await http.post(
      Uri.parse(baseAPIURL+'firebase_notification.php'),
      body: jsonEncode(data),
      headers: _setHeaders()
    );
  }

}