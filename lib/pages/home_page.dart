import 'package:flutter/material.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:xmppflutter/model/user_model.dart';
import 'package:xmppflutter/pages/chat_page.dart';
import 'package:xmppflutter/pages/login_page.dart';
// import 'package:xmppflutter/pages/login_page.dart';

//ignore: must_be_immutable
class HomePage extends StatefulWidget {

  xmpp.Connection _connection;

  HomePage({@required xmpp.Connection connection}){
    this._connection = connection;
  }

  @override
  _HomePageState createState() => _HomePageState(_connection);
}

class _HomePageState extends State<HomePage> {

  xmpp.Connection _connection;
  xmpp.ChatManager _chatManager;
  xmpp.RosterManager _rosterManager;

  _HomePageState(this._connection);

  // สร้างตัวแปรไว้เก็บข้อความ สถานะ
  var subsChat;
  var subsState;
  var subsMessages;

  List<xmpp.Chat> _chats = [];
  // var _chats = allchats.firstWhere((element) => element == [], orElse: () => null);

  @override
  void initState() {
    super.initState();

    new User(jid: _connection.account.fullJid.userAtDomain, password: _connection.account.password);

    subsMessages = xmpp.MessageHandler.getInstance(_connection).messagesStream.listen((event) => setState((){}));

    _chatManager = xmpp.ChatManager.getInstance(_connection);

    subsChat = _chatManager.chatListStream.listen((List<xmpp.Chat> chats){
      _chats.insert(0, chats.last);
      if(chats.last.messages.isNotEmpty) setState(() {});
    });

  }

  @override
  void dispose() {
    super.dispose();
    subsChat.cancel();
    subsState.cancel();
    subsMessages.cancel();
    _connection.close();
  }

  @override
  Widget build(BuildContext context) {

    _rosterManager = xmpp.RosterManager.getInstance(_connection);
    _rosterManager.getRoster().forEach((buddy) { 
      print(buddy.name);
    }); 

    print("Chat length=$_chats.length");

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app), 
            onPressed: (){
              _connection.connect();
              Navigator.pushReplacement(context, 
                MaterialPageRoute(builder: (BuildContext context) => LoginPage())
              );
            }
          )
        ],
      ),
      body: Center(
        child:_chats.length > 0 ? ListView.builder(
          itemCount: _chats.length,
          itemBuilder: (context, index){
            return ListTile(
              leading: Icon(Icons.chat_bubble),
              title: Text(_chats[index].messages.last.text),
              subtitle: Text(_chats[index].jid.local),
              onTap: (){
                Navigator.push(context, 
                  MaterialPageRoute(builder: (BuildContext context) => 
                    ChatPage(chat: _chats[index])
                  )
                );
              },
            );
          }
        ) : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) =>
            AlertDialog(
              content: Container(
                height: 100,
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: TextEditingController(text: "@192.168.1.49"),
                  decoration: InputDecoration(
                    labelText: 'ป้อนชื่อที่ต้องการแชทด้วย'
                  ),
                  onSubmitted: _handleSubmit,
                ),
              ),
            )
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }


  void _handleSubmit(String jid) {

    print(jid);

    if(jid.trim().length > 3){
      final xjid = xmpp.Jid.fromFullJid(jid);
      final xmpp.Chat newChat = _chatManager.getChat(xjid);

      print(xjid);

      Navigator.push(context, 
        MaterialPageRoute(builder: (BuildContext context) => 
          ChatPage(chat: newChat)
        )
      );

    }
  }

}