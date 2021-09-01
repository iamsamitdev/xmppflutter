import 'package:flutter/material.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:xmppflutter/pages/home_page.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XMPP Chat'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login', style: TextStyle(color: Colors.blue, fontSize: 30),),
                  FormLogin(),
                ],
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
  final TextEditingController jidController = new TextEditingController();
  final TextEditingController passController = new TextEditingController();
  
  bool _loading = false;
  bool _error = false;

 @override
  void dispose() {
    super.dispose();
    jidController.dispose();
    passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: jidController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'jid',
              icon: Icon(Icons.alternate_email)
            ),
            validator: (jid){
              if(jid.length > 8){
                return null;
              }else{
                return 'Please check this field.';
              }
            }
          ),
          TextFormField(
            controller: passController,
            keyboardType: TextInputType.emailAddress,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'password',
              icon: Icon(Icons.lock)
            ),
            validator: (pass){
              if(pass.length >= 6){
                return null;
              }else{
                return 'Please check this field.';
              }
            }
          ),
          SizedBox(height: 10,),
          if(_error) Text('Authentication failed: check your details', style: TextStyle(color: Colors.red, fontSize: 16),),
          SizedBox(height: 20),
          _loading ? CircularProgressIndicator() 
          : RaisedButton(
            onPressed: () => _handleLogin(context),
            child: Text('Login'),
            color: Colors.blue[100],
          )
        ],
      )
    );
  }


  // สร้งฟังก์ชันสำหรับ SubmitForm
  _handleLogin(BuildContext context){
    if(!formKey.currentState.validate()) return ;

    formKey.currentState.save();

    setState(() {
      _loading = true;
      // print('$jidController, $passController');
    });

    final jid = xmpp.Jid.fromFullJid(jidController.text.trim());
    final account = xmpp.XmppAccountSettings(jid.userAtDomain, jid.local, jid.domain, passController.text.trim(), 5222, resource: 'xmppstone');
    final _connection   = xmpp.Connection(account);

    _connection.connect();

    // ทำการ listen
    _connection.connectionStateStream.listen((xmpp.XmppConnectionState state) {
      if(state == xmpp.XmppConnectionState.Ready){
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