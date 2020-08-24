import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatScreen extends StatefulWidget {
  static String id="chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController=TextEditingController();
  final _firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messagetext;
  void initState(){
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() async{
    try{
      final user=await _auth.currentUser();
      if(user!=null){
        loggedInUser=user;
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(

              stream: _firestore.collection('msgs').snapshots(),
              builder: (context,snapshot){

                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                  }

                  final messages=snapshot.data.documents.reversed;
                  List<MessageBubble> messageBubbles=[];
                  for(var msg in messages){
                    final txt=msg.data['text'];
                    final sndr=msg.data['sender'];
                    final currentUser=loggedInUser.email;
                    if(currentUser==sndr){

                    }
                    final messageBubble=MessageBubble(
                      sender: sndr,
                      text: txt,
                      isMe:currentUser==sndr,
                    );
                    messageBubbles.add(messageBubble);
                  }

                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    children: messageBubbles,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messagetext=value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('msgs').add({
                        'text':messagetext,
                        'sender':loggedInUser.email,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.text,this.isMe});
  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isMe? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children:<Widget>[
          Text(sender,style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
          Material(
            elevation: 5.0,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30),
        bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)),
        color:isMe?Colors.lightBlueAccent:Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
          child: Text('$text',
            style: TextStyle(
              color: isMe?Colors.white:Colors.black54,
              fontSize: 15.0,
            ),
          ),
        ),
      ),
     ]
      ),
    );
  }
}
