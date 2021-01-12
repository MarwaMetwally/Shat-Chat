import 'package:flutter/material.dart';
import 'package:shatchat/widgets/message.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ChatRoom extends StatefulWidget {
  final String sender;
  final String receiver;
  final String receiverPhoto;
  final String senderPhoto;

  ChatRoom({this.receiver, this.sender, this.receiverPhoto, this.senderPhoto});
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController msg = new TextEditingController();
  FireStoreMethos _fireStoreMethos = new FireStoreMethos();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUser;
  String roomId;
  bool isMe;
  bool loveReact = false;

  @override
  void initState() {
    // setState(() async {
    //   // photo = await _fireStoreMethos.getUserByEmail(widget.sender);

    //   print(photo);
    // });

    currentUser = _auth.currentUser.email;

    roomId = _fireStoreMethos.getDocID(widget.sender, widget.receiver);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).accentColor.withOpacity(0.3),
                Theme.of(context).accentColor.withOpacity(0.1),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // stops: [0.0, 1.0],
              // tileMode: TileMode.clamp,
            ),
          ),
          child: Column(
            children: [
              StreamBuilder(
                stream: _fireStoreMethos.getMessages(roomId),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Expanded(
                        child: ListView.builder(
                      reverse: true,
                      itemCount:
                          snapshot.data != null ? snapshot.data.docs.length : 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onDoubleTap: () {},
                          child: Row(
                            mainAxisAlignment:
                                snapshot.data.docs[index].data()["sender"] ==
                                        currentUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              snapshot.data.docs[index].data()["sender"] !=
                                      currentUser
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: widget.receiverPhoto != null
                                                ? NetworkImage(
                                                    widget.receiverPhoto)
                                                : NetworkImage(
                                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'),
                                          )),
                                    )
                                  : Container(),
                              Stack(children: [
                                GestureDetector(
                                  onDoubleTap: () {
                                    print(' indexxxlisttt$index');
                                    setState(() {
                                      loveReact = !loveReact;
                                    });
                                  },
                                  child: MessageBubble(
                                      isMe: snapshot.data.docs[index]
                                              .data()["sender"] ==
                                          currentUser,
                                      sender: snapshot.data.docs[index]
                                          .data()["sender"],
                                      text: snapshot.data.docs[index]
                                          .data()["msg"]),
                                ),
                                Positioned(
                                    top: 30,
                                    left: snapshot.data.docs[index]
                                                .data()["sender"] ==
                                            currentUser
                                        ? 0
                                        : 175,
                                    child: loveReact
                                        ? Icon(Icons.favorite,
                                            size: 22, color: Colors.red[700])
                                        : Container()),
                              ]),
                              snapshot.data.docs[index].data()["sender"] ==
                                      currentUser
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: widget.senderPhoto != null
                                                ? NetworkImage(
                                                    widget.senderPhoto)
                                                : NetworkImage(
                                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'),
                                          )),
                                    )
                                  : Container(),
                            ],
                          ),
                        );
                      },
                    ));
                  } else {
                    return Container();
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: msg,
                        decoration: InputDecoration(
                            hintText: 'write the message',
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        Map<String, String> chatMap = {
                          "sender": currentUser,
                          "msg": msg.text,
                          "time": DateTime.now().toString(),
                        };
                        _fireStoreMethos.createChatRoom(roomId, chatMap);
                        msg.clear();
                      },
                      child: Icon(Icons.arrow_forward_ios))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
