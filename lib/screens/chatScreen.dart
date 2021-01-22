import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shatchat/screens/profile.dart';
import 'package:shatchat/screens/signin.dart';
import 'chatroom.dart';
import 'package:shatchat/screens/searchscreen.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:shatchat/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  // final String senderPhoto;
  // ChatScreen(this.senderPhoto);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  FireStoreMethos fireStoreMethos = new FireStoreMethos();
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static String receiver;
  Auth auth = new Auth();
  String phone;
  int snapshotIndex;
  String userName;
  String email;
  String sender = _auth.currentUser.email;
  Stream datalist;
  String senderpPhoto;
  List<String> users = [];
  List<String> roomID = [];

  @override
  void initState() {
    print(_auth.currentUser.email);
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        fireStoreMethos.updateStatus(false, _auth.currentUser.uid);
        break;
      case AppLifecycleState.resumed:
        fireStoreMethos.updateStatus(true, _auth.currentUser.uid);
        break;
      case AppLifecycleState.inactive:
        print('inactive');
        break;
      case AppLifecycleState.detached:
        print('detacch');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
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
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
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
              color: Color(0xff45b591).withOpacity(0.2),
            ),
            height: 70,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Container(
                //   height: 45,
                //   width: 45,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(25),
                //     // image: DecorationImage(
                //     //   image: NetworkImage(widget.senderPhoto),
                //     //   fit: BoxFit.fill,
                //     // )
                //   ),
                // ),
                SizedBox(
                  width: 30,
                ),
                Text(
                  'Chats',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 27),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: fireStoreMethos.friends(_auth.currentUser.email),
              builder: (context, chatroomsnapshot) {
                if (chatroomsnapshot.data != null) {
                  if (chatroomsnapshot.data.docs.length == 0) {
                    return Lottie.asset('assets/6192-mobile-chat.json');
                  }
                  for (int i = 0; i < chatroomsnapshot.data.docs.length; i++) {
                    snapshotIndex = i;
                    print('ind $snapshotIndex');
                    roomID.add(
                        chatroomsnapshot.data.docs[snapshotIndex].documentID);
                    print(roomID[i]);
                    email = roomID[i]
                        .replaceAll(_auth.currentUser.email, "")
                        .replaceAll('-', "");
                    print(email);
                    users.add(email);
                  }

                  return FutureBuilder(
                    future: fireStoreMethos.getAllUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data == null) {
                        return Container();
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                receiver =
                                    snapshot.data.docs[index].data()["email"];

                                phone =
                                    snapshot.data.docs[index].data()["phone"];
                                senderpPhoto = await fireStoreMethos
                                    .getUserPhoto(_auth.currentUser.uid);
                                print(
                                    snapshot.data.docs[index].data()["status"]);

                                print(snapshot.data.docs[index].data()["name"]);
                                print(receiver);
                                print(sender);
                                print(
                                    snapshot.data.docs[index].data()["photo"]);
                                print(senderpPhoto);
                                print('phoneeeeee$phone');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoom(
                                          active: snapshot.data.docs[index]
                                              .data()["status"],
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
                                  ? StreamBuilder(
                                      stream: fireStoreMethos.getLastMessage(
                                          roomID[users.indexOf(snapshot
                                              .data.docs[index]
                                              .data()["email"])]),
                                      builder: (context, msgsnapshot) {
                                        if (msgsnapshot.data != null) {
                                          String msg = msgsnapshot.data.docs[0]
                                              .data()["msg"];
                                          String date = DateFormat()
                                              .add_jm()
                                              .format(DateTime.parse(msgsnapshot
                                                  .data.docs[0]
                                                  .data()["time"]
                                                  .toDate()
                                                  .toString()));
                                          print(index);
                                          print(snapshot.data.docs[index]
                                              .data()["photo"]);
                                          return ChatTile(
                                            active: snapshot.data.docs[index]
                                                .data()["status"],
                                            photoUrl: snapshot.data.docs[index]
                                                .data()["photo"],
                                            username: snapshot.data.docs[index]
                                                .data()["name"],
                                            recentMsg:
                                                msg.contains('firebasestorage')
                                                    ? 'photo'
                                                    : msg,
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
                      }
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          )
        ]),
      ),
      icon: AnimatedIcons.menu_arrow,
      fabColor: Theme.of(context).accentColor,
      iconColor: Colors.white,
      items: [
        HawkFabMenuItem(
          label: 'Profile',
          ontap: () async {
            senderpPhoto =
                await fireStoreMethos.getUserPhoto(_auth.currentUser.uid);
            userName = await fireStoreMethos.getUserName(_auth.currentUser.uid);
            phone = await fireStoreMethos.getUserPhone(_auth.currentUser.uid);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => ProfileScreen(
                        sender: true,
                        phone: phone,
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
          ontap: () async {
            await auth.signOut().then((value) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SignIn()));
            });
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

class ChatTile extends StatelessWidget {
  final String username;
  final String recentMsg;
  final String photoUrl;
  final String time;
  final bool active;
  ChatTile(
      {this.username, this.photoUrl, this.recentMsg, this.time, this.active});
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        width: width,
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
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 10),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : AssetImage('assets/images/profile.jpg'))),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: active ? Colors.green : Colors.grey,
                      radius: 7,
                    ),
                  )
                ],
              ),
              Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username),
                      Text(
                        recentMsg.length > (width * 0.065).toInt()
                            ? recentMsg.substring(0, (width * 0.065).toInt()) +
                                '...'
                            : recentMsg,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
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
    );
  }
}
