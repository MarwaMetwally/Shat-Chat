import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatchat/screens/chatroom.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:shatchat/widgets/searchList.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  double appBarHeight = AppBar().preferredSize.height;
  List<QueryDocumentSnapshot> filteredusers = [];
  FireStoreMethos firestore = new FireStoreMethos();
  List<QueryDocumentSnapshot> users;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 17),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back,
                      color: Theme.of(context).accentColor),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  child: Row(
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Theme.of(context).accentColor,
                      //   child: Icon(
                      //     Icons.search,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) async {
                            users = await firestore.getUserByUserName();
                            setState(() {
                              users.forEach((element) {
                                filteredusers = double.tryParse(value) == null
                                    ? users
                                        .where((element) => element
                                            .data()["name"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(value))
                                        .toList()
                                    : users
                                        .where((element) => element
                                            .data()["phone"]
                                            .contains(value))
                                        .toList();
                              });
                            });
                          },
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
                              prefixIcon: Icon(
                                Icons.search,
                                //  color: Theme.of(context).accentColor,
                              ),
                              hintText: 'User Name or User Phone',
                              contentPadding: EdgeInsets.only(left: 20),
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: filteredusers.length,
                itemBuilder: (context, index) => filteredusers[index]
                            .data()["email"] !=
                        FirebaseAuth.instance.currentUser.email
                    ? SearchTile(
                        username: filteredusers[index].data()["name"],
                        photoUrl: filteredusers[index].data()["photo"],
                        onPressed: () async {
                          String photo = await firestore.getUserPhoto(
                              FirebaseAuth.instance.currentUser.uid);
                          String phone = await firestore.getUserPhoto(
                              FirebaseAuth.instance.currentUser.uid);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (ctx) => ChatRoom(
                                        active: filteredusers[index]
                                            .data()["status"],
                                        receiverPhoto: filteredusers[index]
                                            .data()["photo"],
                                        receiver: filteredusers[index]
                                            .data()["email"],
                                        senderPhoto: photo,
                                        receiverName:
                                            filteredusers[index].data()["name"],
                                        receiverPhone:
                                            phone == null ? "" : phone,
                                        sender: FirebaseAuth
                                            .instance.currentUser.email,
                                      )));
                        })
                    : Container(),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
