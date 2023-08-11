import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


final _firestore = FirebaseFirestore.instance;
late User loggedInUser;


class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late String messageText;
  final messageTextController = TextEditingController();



  void getCurrentUser() async {
    try {
      final _user = await _auth.currentUser!;
      if (_user != null) {
        loggedInUser = _user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() {
  //   _firestore.collection('messages').get().then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       print(doc.data());
  //       print(doc['sender']);
  //       print(doc['text']);
  //
  //     });
  //   });
  // }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      // random snapshots & start iterating thru them
      // like we 2 in a row then 1
      for (var doc in snapshot.docs) {
        // we iterate thru the snapshot's docs property which will give us a single row
        print(doc.data());
      }
    };
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    //messagesStream();

    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
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
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email, 'time': DateTime.now()}
                      );
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

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy("time", descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data?.docs.reversed;
          List<MessageBubble> messageWidgets = [];
          for (var message in messages!) {
            var sender = message['sender'];
            var text = message['text'];
            Color color = loggedInUser.email ==sender ? Colors.lightBlueAccent: Colors.grey;
            messageWidgets
                .add(MessageBubble(text: text, sender: sender, color: color,));
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageWidgets,
            ),
          );
        }
        return Column(
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ),
          ],
        );
      },
    );
  }
}


class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.text, required this.sender, required this.color});

  final String text;
  final String sender;
  final color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: color == Colors.lightBlueAccent? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontSize: 12, color: Colors.black54),),
          Material(
            borderRadius: (color == Colors.lightBlueAccent?
            BorderRadius.only( topLeft: Radius.circular(30), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)):
            BorderRadius.only( topRight: Radius.circular(30), bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
            elevation: 5,
            color: color,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(
                '$text',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
