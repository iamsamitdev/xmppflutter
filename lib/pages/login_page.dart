import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:xmppflutter/pages/home_page.dart';

import 'package:xmppflutter/services/rest_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XMPP Chat'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.all(30),
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('XMPP Login', style: TextStyle(color: Colors.blue, fontSize: 30),),
                    SizedBox(height: 20,),
                    FormLogin()
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}

class FormLogin extends StatefulWidget {
  @override
  _FormLoginState createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {

  // Key สำหรับไว้ผูกกับฟอร์ม
  final formKey = GlobalKey<FormState>();

  // สร้างตัวแปรเก็บ userid กับ password
  final TextEditingController username = new TextEditingController(text: "wichai");
  final TextEditingController password = new TextEditingController(text: "123456");
  final TextEditingController host = new TextEditingController(text: "@192.168.1.49");
  final int port = 5222;
  
  bool _loading = false;
  bool _error = false;

 @override
  void dispose() {
    super.dispose();
    username.dispose();
    password.dispose();
    host.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: username,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Username',
              icon: Icon(Icons.person),
            ),
            validator: (jid){
              if(jid.length >= 3){
                return null;
              }else{
                return 'ป้อนข้อมูลนี้ก่อน';
              }
            }
          ),
          TextFormField(
            controller: host,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Host name',
              icon: Icon(Icons.domain),
            ),
            validator: (jid){
              if(jid.length > 8){
                return null;
              }else{
                return 'ป้อนข้อมูลนี้ก่อน';
              }
            }
          ),
          TextFormField(
            controller: password,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              icon: Icon(Icons.lock)
            ),
            validator: (pass){
              if(pass.length >= 6){
                return null;
              }else{
                return 'ป้อนข้อมูลนี้ก่อน';
              }
            }
          ),
          SizedBox(height: 10,),
          if(_error) Text('ข้อมูลเข้าระบบไม่ถูกต้อง ลองใหม่', style: TextStyle(color: Colors.red, fontSize: 16),),
          SizedBox(height: 20),
          _loading ? CircularProgressIndicator() 
          : RaisedButton(
            onPressed: () => _handleLogin(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Login', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
            color: Colors.blue,
          )
        ],
      )
    );
  }


  // สร้งฟังก์ชันสำหรับ SubmitForm
  _handleLogin(BuildContext context) {
    if(!formKey.currentState.validate()) return ;

    formKey.currentState.save();

    setState(() {
      _loading = true;
      // print('$jidController, $passController');
    });

    final jid = xmpp.Jid.fromFullJid(username.text.trim()+host.text.trim());
    final account = xmpp.XmppAccountSettings(jid.userAtDomain, jid.local, jid.domain, password.text.trim(), port, resource: 'xmppstone');
    final _connection   = xmpp.Connection(account);

    _connection.connect();

    // ทำการ listen
    _connection.connectionStateStream.listen((xmpp.XmppConnectionState state) async {
      if(state == xmpp.XmppConnectionState.Ready){

        // อ่านค่าจากตัวแปรแบบ sharedPreferences
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

        // เมื่อ login ผ่านแล้วให้ทำการ register device ตรงนี้
        var token = sharedPreferences.getString('token');

        // เรียกใช้งาน API Register Device
        var response = await CallAPI().registerDevice(
          {
            "username": username.text.trim(),
            "token": token
          }
        );

        var body = json.decode(response.body);

        print(body);

        // ส่งไปหน้า HomePage
        Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (BuildContext context) => 
            HomePage(connection: _connection))
        );
      }else{
        setState(() {
          _loading =false;
          _error = true;
        });
      }
    });
  }


}