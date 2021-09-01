import 'package:flutter/material.dart';
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:xmppflutter/model/user_model.dart';

class ChatPage extends StatefulWidget {

   xmpp.Chat _chat;

  ChatPage( {@required xmpp.Chat chat} ){
    this._chat = chat;
  }

  @override
  _ChatPageState createState() => _ChatPageState(this._chat);
}

class _ChatPageState extends State<ChatPage> {

  _ChatPageState(this._chat);

  xmpp.Chat _chat;

  List<MessageChat> _messages = [];

  TextEditingController _messageController = TextEditingController();

  var subs;

  @override
  void initState() {
    super.initState();

    _chat.messages.forEach((message) { 
      _messages.insert(0, MessageChat(jid:message.from.userAtDomain,text: message.text,));
    });

     subs = _chat.newMessageStream.listen((xmpp.Message message) {
       if(message.from.userAtDomain != User.getUser.jid){
          setState(() {
            _messages.insert(0,MessageChat(jid: message.from.userAtDomain,text: message.text));
          });
       }

    });
    
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    subs.cancle();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chat.jid.local),
      ),
      body: Container(
        color: Colors.black12,
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                
                itemCount: _messages.length,
                itemBuilder: (ctx,i) => _messages[i],
                reverse: true,
              )
            ),
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  _inputMessage(),
                  IconButton(
                    color: Colors.blue,
                    icon: Icon(Icons.send),
                    onPressed: _handleSend
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _handleSend(){

    if(_messageController.text.length > 0){

      _chat.sendMessage(_messageController.text);
      _messages.insert(0,MessageChat(jid:User.getUser.jid,text:_messageController.text));
      setState(() {
        _messageController.text = '';
      });
    }

  }

  
  Widget _inputMessage(){
    return Flexible(
      child: SafeArea(
          child: Container(
          height: 40,
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
          ),
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Write'
            ),
          ),
        ),
      ),
    );
  }

}
  

class MessageChat extends StatelessWidget {
  
  final String text;
  final String jid;

  const MessageChat({Key key, this.text, this.jid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (jid == User.getUser.jid)
      ? Align(
        alignment: Alignment.bottomRight,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          margin: EdgeInsets.only(bottom: 5,left: 100,right: 5),
          decoration: BoxDecoration(
            color: Colors.green[300],
            borderRadius: BorderRadius.circular(100)
          ),
          child: Text(text,style: TextStyle(color: Colors.white),),
        ),
      )
      :Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          margin: EdgeInsets.only(bottom: 5,left: 5,right: 100),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100)
          ),
          child: Text(text),
        ),
      );
  }
}