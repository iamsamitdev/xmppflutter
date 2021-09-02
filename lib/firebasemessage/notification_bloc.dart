// Class กลางสำหรับใช้งานกับจุดอื่นๆ ในโปรเจ็กต์ของเรา
// Singelton Class

import 'dart:async';

class NotificationsBloc {

  NotificationsBloc._internal(){
    _notificationStreamController.onListen = _onListen;
  }

  static final NotificationsBloc instance = NotificationsBloc._internal();
  bool _sendBufferedEvents = true;
  Map<String, dynamic> _bufferedEvent;

  Stream<Map<String,dynamic>> get notificationStream => _notificationStreamController.stream;

  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();

  // Method สำหรับการเฝ้าดูการรับส่งข้อมูล
  _onListen(){
    if(_sendBufferedEvents){
      if(_bufferedEvent != null){
        _notificationStreamController.sink.add(_bufferedEvent);
      }
      _sendBufferedEvents = false;
    }
  }

  // Method สำหรับส่งข้อความใหม่
  void newNotification(Map<String, dynamic> notification) {
    if(_sendBufferedEvents){
      _bufferedEvent = notification;
    }else{
      _notificationStreamController.sink.add(notification);
    }
  }

  void dispose(){
    _notificationStreamController.close();
  }

}
