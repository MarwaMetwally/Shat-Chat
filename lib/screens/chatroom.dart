import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatchat/screens/profile.dart';
import 'package:shatchat/widgets/message.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  final String sender;
  final String receiver;
  final String receiverPhoto;
  final String senderPhoto;
  final String receiverName;
  final String receiverPhone;

  ChatRoom(
      {this.receiver,
      this.sender,
      this.receiverPhoto,
      this.senderPhoto,
      this.receiverName,
      this.receiverPhone});
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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.dstATop),
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover),
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).accentColor.withOpacity(0.3),
                    width: 1)),
            color: Color(0xff45b591).withOpacity(0.2),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => ProfileScreen(
                                userName: widget.receiverName,
                                photo: widget.receiverPhoto,
                                phone: widget.receiverPhone == null
                                    ? ""
                                    : widget.receiverPhone,
                              )));
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.3),
                            width: 1)),
                    color: Color(0xff45b591).withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: NetworkImage(widget.receiverPhoto),
                                fit: BoxFit.contain,
                              )),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text(widget.receiverName),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _fireStoreMethos.getMessages(roomId),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data != null
                            ? snapshot.data.docs.length
                            : 0,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              // snapshot.data.docs[index].data()["sender"] !=
                              //         currentUser
                              //     ? Container(
                              //         height: 40,
                              //         width: 40,
                              //         decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(25),
                              //             image: DecorationImage(
                              //               fit: BoxFit.contain,
                              //               image: widget.receiverPhoto != null
                              //                   ? NetworkImage(
                              //                       widget.receiverPhoto)
                              //                   : NetworkImage(
                              //                       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'),
                              //             )),
                              //       )
                              //     : Container(),
                              GestureDetector(
                                onDoubleTap: () {
                                  setState(() {
                                    loveReact = !loveReact;
                                    _fireStoreMethos.upateReact(
                                        loveReact,
                                        roomId,
                                        snapshot.data.docs[index].documentID);
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 50),
                                  child: Message(
                                      time: DateFormat().add_jm().format(
                                          DateTime.parse(snapshot
                                              .data.docs[index]
                                              .data()["time"]
                                              .toDate()
                                              .toString())),
                                      isMe: snapshot.data.docs[index]
                                              .data()["sender"] ==
                                          currentUser,
                                      text: snapshot.data.docs[index]
                                          .data()["msg"]),
                                ),
                              ),
                              Positioned(
                                  top: 40,
                                  right: snapshot.data.docs[index]
                                              .data()["sender"] ==
                                          currentUser
                                      ? 150
                                      : 50,
                                  child:
                                      snapshot.data.docs[index].data()["liked"]
                                          ? Icon(Icons.favorite,
                                              size: 22, color: Colors.red[700])
                                          : Container()),
                              snapshot.data.docs[index].data()["sender"] ==
                                      currentUser
                                  ? Positioned(
                                      right: 10,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              image: DecorationImage(
                                                fit: BoxFit.contain,
                                                image: widget.senderPhoto !=
                                                        null
                                                    ? NetworkImage(
                                                        widget.senderPhoto)
                                                    : NetworkImage(
                                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'),
                                              )),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 45,
                        child: Center(
                          child: TextField(
                            cursorColor: Theme.of(context).accentColor,
                            //  autofocus: true,
                            textAlign: TextAlign.left,
                            enabled: true,
                            controller: msg,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                                hintText: 'write the message',
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    GestureDetector(
                        onTap: () {
                          Map<String, dynamic> chatMap = {
                            "sender": currentUser,
                            "msg": msg.text,
                            "time": Timestamp.now(),
                            "liked": false
                          };
                          Map<String, dynamic> roomMap = {
                            "time": DateTime.now().toString(),
                            "users": [currentUser, widget.receiver],
                          };
                          print(chatMap["sender"]);
                          print(currentUser);
                          _fireStoreMethos.createChatRoom(
                              roomId, chatMap, roomMap);
                          msg.clear();
                        },
                        child: Icon(
                          Icons.send,
                          size: 30,
                          color: Theme.of(context).accentColor,
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
