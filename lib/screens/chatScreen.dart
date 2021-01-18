import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatchat/helper/authenticate.dart';
import 'package:shatchat/screens/profile.dart';
import 'chatroom.dart';
import 'package:shatchat/screens/searchscreen.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:shatchat/services/auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String senderPhoto;
  ChatScreen(this.senderPhoto);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FireStoreMethos fireStoreMethos = new FireStoreMethos();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static User currentuser = _auth.currentUser;
  static String receiver;
  Auth auth = new Auth();
  String phone;
  int snapshotIndex;
  String userName;
  String email;
  static String sender = currentuser.email;
  Stream datalist;
  String senderpPhoto;
  List<String> users = [];
  List<String> roomID = [];
  @override
  void initState() {
    //print('senderrr ${widget.senderPhoto}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HawkFabMenu(
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
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       Theme.of(context).accentColor.withOpacity(0.3),
        //       Theme.of(context).accentColor.withOpacity(0.1),
        //       Colors.white,
        //     ],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     // stops: [0.0, 1.0],
        //     // tileMode: TileMode.clamp,
        //   ),
        // ),
        child: Column(children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30)),
              image: DecorationImage(
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.dstATop),
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover),
              // border: Border(
              //     bottom: BorderSide(
              //         color: Theme.of(context).accentColor.withOpacity(0.3),
              //  width: 1)),
              color: Color(0xff45b591).withOpacity(0.2),
            ),
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        image: DecorationImage(
                          image: NetworkImage(widget.senderPhoto),
                          fit: BoxFit.contain,
                        )),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text('Chats'),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: fireStoreMethos.friends(currentuser.email),
            builder: (context, chatroomsnapshot) {
              if (chatroomsnapshot.data != null) {
                for (int i = 0; i < chatroomsnapshot.data.docs.length; i++) {
                  snapshotIndex = i;
                  //      print('ind $snapshotIndex');
                  roomID.add(
                      chatroomsnapshot.data.docs[snapshotIndex].documentID);
                  //   print(roomID[i]);
                  email = roomID[i]
                      .replaceAll(currentuser.email, "")
                      .replaceAll('-', "");
                  //   print(email);
                  users.add(email);
                }

                return Expanded(
                  child: FutureBuilder(
                    future: fireStoreMethos.getAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  receiver =
                                      snapshot.data.docs[index].data()["email"];
                                });
                                senderpPhoto = await fireStoreMethos
                                    .getUserPhoto(currentuser.uid);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoom(
                                          receiverPhone: phone,
                                          receiverName: snapshot
                                              .data.docs[index]
                                              .data()["name"],
                                          receiver: receiver,
                                          sender: sender,
                                          receiverPhoto: snapshot
                                                      .data.docs[index]
                                                      .data()["photo"] ==
                                                  null
                                              ? ""
                                              : snapshot.data.docs[index]
                                                  .data()["photo"],
                                          senderPhoto: senderpPhoto),
                                    ));
                              },
                              child: users.contains(
                                      snapshot.data.docs[index].data()["email"])
                                  ? FutureBuilder(
                                      future: fireStoreMethos
                                          .getLastMessage(roomID[index]),
                                      builder: (context, msgsnapshot) {
                                        if (msgsnapshot.data != null) {
                                          String date = DateFormat()
                                              .add_jm()
                                              .format(DateTime.parse(msgsnapshot
                                                  .data.docs[0]
                                                  .data()["time"]
                                                  .toDate()
                                                  .toString()));
                                          // print(date);
                                          return SearchTile(
                                            photoUrl: snapshot.data.docs[index]
                                                .data()["photo"],
                                            username: snapshot.data.docs[index]
                                                .data()["name"],
                                            recentMsg: msgsnapshot.data.docs[0]
                                                .data()["msg"],
                                            time: date,
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    )
                                  : Container(),
                            );
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ]),
      ),
      icon: AnimatedIcons.menu_arrow,
      fabColor: Theme.of(context).accentColor,
      iconColor: Colors.white,
      items: [
        HawkFabMenuItem(
          label: 'Profile',
          ontap: () async {
            senderpPhoto = await fireStoreMethos.getUserPhoto(currentuser.uid);
            userName = await fireStoreMethos.getUserName(currentuser.uid);
            phone = await fireStoreMethos.getUserPhone(currentuser.uid);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => ProfileScreen(
                        phone: phone == null ? "" : phone,
                        userName: userName,
                        photo: senderpPhoto == null
                            ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'
                            : senderpPhoto)));
          },
          icon: Icon(
            Icons.edit,
            color: Theme.of(context).accentColor,
          ),
          color: Colors.white,
          labelColor: Theme.of(context).accentColor,
        ),
        HawkFabMenuItem(
            label: 'Search',
            ontap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (ctx) => SearchScreen()));
            },
            icon: Icon(
              Icons.search,
              color: Theme.of(context).accentColor,
            ),
            color: Colors.white,
            labelColor: Colors.white,
            labelBackgroundColor: Theme.of(context).accentColor),
        HawkFabMenuItem(
          color: Colors.white,
          label: 'Logout',
          ontap: () {
            auth.signOut().then((value) => Navigator.push(
                context, MaterialPageRoute(builder: (ctx) => Authenticate())));
          },
          labelColor: Theme.of(context).accentColor,
          labelBackgroundColor: Colors.white,
          icon: Icon(
            Icons.logout,
            color: Theme.of(context).accentColor,
          ),
        ),
      ],
    ));
  }
}

class SearchTile extends StatelessWidget {
  final String username;
  final String recentMsg;
  final String photoUrl;
  final String time;
  SearchTile({this.username, this.photoUrl, this.recentMsg, this.time});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  spreadRadius: 0.1,
                  blurRadius: 0.5,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10)),
          height: 80,

          //   color: Theme.of(context).accentColor.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 10),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        image: DecorationImage(
                            fit: BoxFit.contain,
                            image: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : AssetImage('assets/images/profile.jpg'))),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username),
                      Text(
                        recentMsg,
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
                Text(time.toString(),
                    style: TextStyle(
                      color: Colors.grey,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
