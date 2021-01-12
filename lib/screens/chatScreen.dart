import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chatroom.dart';
import 'package:shatchat/screens/searchscreen.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FireStoreMethos fireStoreMethos = new FireStoreMethos();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static User currentuser = _auth.currentUser;
  static String receiver;
  static String sender = currentuser.email;
  List<String> emails = [];
  String senderpPhoto;
  @override
  void initState() {
    senderpPhoto = fireStoreMethos.getUserPhoto(currentuser.uid);
    print('senderrr $senderpPhoto');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => SearchScreen())),
      ),
      body: FutureBuilder(
        future: fireStoreMethos.getAllUsers(),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, i) {
                    //   emails.add(snapshot.data.docs[i].data()["photo"]);
                    // setState(() {
                    //   //  senderpPhotoindex = emails.indexOf(sender);
                    // });
                    //  print('emaiiil${emails[i]}');
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          receiver = snapshot.data.docs[i].data()["email"];
                        });

                        print('send $sender');
                        print('reee $receiver');
                        print(snapshot.data.docs[i].data()["photo"]);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                  receiver: receiver,
                                  sender: sender,
                                  receiverPhoto:
                                      snapshot.data.docs[i].data()["photo"],
                                  senderPhoto: senderpPhoto),
                            ));
                      },
                      child: SearchTile(
                        photoUrl: snapshot.data.docs[i].data()["photo"],
                        username: snapshot.data.docs[i].data()["name"],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class SearchTile extends StatelessWidget {
  final String username;
  // final String email;
  final String photoUrl;
  SearchTile({this.username, this.photoUrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: photoUrl != null
                          ? NetworkImage(photoUrl)
                          : AssetImage('assets/images/Gmail-logo.png'))),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(username)],
            ),
          ],
        ),
      ),
    );
  }
}
