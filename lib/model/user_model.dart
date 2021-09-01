import 'package:xmpp_stone/xmpp_stone.dart';

class User {

  static User user = new User._();

  String jid = '';
  String password = '';
  bool loggedin = false;

  User._();

  factory User({jid, password}){
    user.jid = jid;
    user.password = password;
    user.loggedin = true;
    
    return user;
  }

  static User get getUser {
    return user;
  }

}