import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_bloc.dart';

class NotificationService {

  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  // เรียกใช้งาน Firebase Messesging
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // เรียกใช้งาน Flutter Local Notification
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  // สร้างตัวแปรไว้สำหรับเก็บ id ของ Flutter Local Notification
  int _count = 0;

  // กำหนดตัวแปรสำหรับเช็คว่า NotificationService อยู่สถานะ start หรือไม่
  bool _started  = false;

  // สร้างฟังก์ชันสำหรับเรียกใช้งาน method ต่างของ service นี้
  void start(){
    if(!_started ){
      _integrateNotification();
      _refreshToken();
      _started = true;
    }
  }

  // Call this method to initialize notification
  // ฟังกชันก์เริ่มต้นเรียกใช้งาน firebase
  void _integrateNotification(){
    _registerNotification();
    _initializeLocalNotification();
  }


  // initialize firebase_messaging plugin
  // สร้างฟังก์ชันการทำงานกับ firebase_messaging
  void _registerNotification(){
    
    // การขอ permission เครื่องเพื่อใช้แจ้งเตือน
    _firebaseMessaging.requestNotificationPermissions();

    // การ config
    _firebaseMessaging.configure(
      onMessage: _onMessage,
      onLaunch: _onLaunch,
      onResume: _onResume,
    );

    // กรณีเครื่องใช้งานครั้งแรก
    _firebaseMessaging.onTokenRefresh.listen(_tokenRefresh, onError: _tokenRefreshFailure);

  }

  void _refreshToken(){
    _firebaseMessaging.getToken().then((token) async {
      print('token $token');
    }, onError: _tokenRefreshFailure);
  }

  // This method will be called device token get refreshed
  void _tokenRefresh(String newToken) async {
    print('New Token : $newToken');
  }

  void _tokenRefreshFailure(error) {
    print("FCM token refresh failed with error $error");
  }

  // App in foreground -> [onMessage] callback will be called
  Future<void> _onMessage(Map<String, dynamic> message) async {
    
    print('onMessage: $message');
    
    if(Platform.isIOS){
      message = _modifyNotificationJson(message);
    }

    _showNotification(
      {
        "title": message['notification']['title'],
        "body": message['notification']['body'],
        "data": message['data'],
      },
    );

  }

  // This method will modify the message format of iOS Notification Data
  Map _modifyNotificationJson(Map<String, dynamic> message) {
    message['data'] = Map.from(message ?? {});
    message['notification'] = message['aps']['alert'];
    return message;
  }

  // tap of any notification (onLaunch / onMessage / onResume)
  void _performActionOnNotification(Map<String, dynamic> message) {
    NotificationsBloc.instance.newNotification(message);
  }

  // used for sending push notification when app is in foreground
  void _showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'Notification Test',
      'Notification Test',
      '',
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      ++_count,
      message['title'],
      message['body'],
      platformChannelSpecifics,
      payload: json.encode(
        message['data'],
      ),
    ); 
  }

  // App terminated -> Notification is delivered to system tray. When the user clicks on it to open app [onLaunch] 
  Future<void> _onLaunch(Map<String, dynamic> message) {
    print('onLaunch: $message');
    if(Platform.isIOS){
      message = _modifyNotificationJson(message);
    }
    _performActionOnNotification(message);
    return null;
  }

  // App in background -> Notification is delivered to system tray. When the user clicks on it to open app [onResume]
  Future<void> _onResume(Map<String, dynamic> message) {
    print('onResume: $message');
    if(Platform.isIOS){
      message = _modifyNotificationJson(message);
    }
    _performActionOnNotification(message);
    return null;
  }


  // initialize flutter_local_notification plugin
  // เรียกจัดการ notification ภายในเครื่องเรา
  void _initializeLocalNotification() {
    // Settings for Android
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Settings for iOS
    var iosInitializationSettings = new IOSInitializationSettings();
    _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      ),
      onSelectNotification: _onSelectLocalNotification,
    );
  }

  // This method will be called on tap of notification pushed by flutter_local_notification plugin when app is in foreground
  Future _onSelectLocalNotification(String payLoad) {
    Map data = json.decode(payLoad);
    Map<String, dynamic> message = {
      "data": data,
    };
    _performActionOnNotification(message);
    return null;
  }

}