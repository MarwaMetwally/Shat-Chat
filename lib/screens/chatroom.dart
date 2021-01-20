import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatchat/screens/profile.dart';
import 'package:shatchat/widgets/message.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path/path.dart' as path;

class ChatRoom extends StatefulWidget {
  final String sender;
  final String receiver;
  final String receiverPhoto;
  final String senderPhoto;
  final String receiverName;
  final String receiverPhone;
  final bool active;

  ChatRoom(
      {this.receiver,
      this.active,
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
  final picker = ImagePicker();
  File _image;
  String imageUrl;

  Future<void> uploadImageToFirebase() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
    if (_image != null) {
      String fileName = path.basename(_image.path);

      storage.Reference firebaseStorageRef =
          storage.FirebaseStorage.instance.ref().child(fileName);

      storage.UploadTask uploadTask = firebaseStorageRef.putFile(_image);

      storage.TaskSnapshot taskSnapshot = await uploadTask;
      taskSnapshot.ref.getDownloadURL().then((value) {
        setState(() {
          print("Done: $value");
          print(value);
          imageUrl = value;

          if (imageUrl != null) {
            Map<String, dynamic> chatMap = {
              "sender": currentUser,
              "msg": imageUrl,
              "time": Timestamp.now(),
              "liked": false,
              "photo": true
            };
            Map<String, dynamic> roomMap = {
              "time": DateTime.now().toString(),
              "users": [currentUser, widget.receiver],
            };

            _fireStoreMethos.createChatRoom(roomId, chatMap, roomMap);
          }

          // return value;
        });
      });
    }
  }

  @override
  void initState() {
    currentUser = _auth.currentUser.email;
    print('sender${widget.sender}');
    print('rec${widget.receiver}');
    roomId = _fireStoreMethos.getDocID(widget.sender, widget.receiver);
    print(roomId);

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
                                sender: false,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.receiverName),
                            widget.active
                                ? Text(
                                    'online',
                                    style: TextStyle(color: Colors.green[700]),
                                  )
                                : Container(),
                          ],
                        ),
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
                        itemCount: snapshot.data != null
                            ? snapshot.data.docs.length
                            : 0,
                        itemBuilder: (context, index) {
                          if (snapshot.data != null &&
                              snapshot.connectionState !=
                                  ConnectionState.waiting) {
                            return Stack(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: snapshot.data.docs[index]
                                                  .data()["sender"] ==
                                              currentUser
                                          ? const EdgeInsets.only(right: 50)
                                          : const EdgeInsets.only(left: 47),
                                      child: Message(
                                          msgphoto: snapshot.data.docs[index]
                                              .data()["photo"],
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
                                  ],
                                ),
                                Positioned(
                                  right: snapshot.data.docs[index]
                                              .data()["sender"] ==
                                          currentUser
                                      ? 10
                                      : null,
                                  left: snapshot.data.docs[index]
                                              .data()["sender"] ==
                                          currentUser
                                      ? null
                                      : 10,
                                  top: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: snapshot.data.docs[index]
                                                        .data()["sender"] ==
                                                    currentUser
                                                ? widget.senderPhoto != null
                                                    ? NetworkImage(
                                                        widget.senderPhoto)
                                                    : NetworkImage(
                                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU')
                                                : widget.receiverPhoto != null
                                                    ? NetworkImage(
                                                        widget.receiverPhoto)
                                                    : NetworkImage(
                                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'),
                                          )),
                                    ),
                                  ),
                                )
                              ],
                            );
                          } else {
                            return Container();
                          }
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
                child: Container(
                  //  height: 50,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo,
                            size: 30, color: Theme.of(context).accentColor),
                        onPressed: () async {
                          await uploadImageToFirebase();
                        },
                      ),
                      Expanded(
                        child: Container(
                          height: 45,
                          child: Center(
                            child: TextField(
                              cursorColor: Theme.of(context).accentColor,
                              //  autofocus: true,
                              textAlign: TextAlign.left,
                              enabled: true,
                              controller: msg,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.all(8.0), //here your padding
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
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
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
                              "liked": false,
                              "photo": false
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
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
