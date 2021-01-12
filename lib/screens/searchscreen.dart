import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:shatchat/widgets/searchList.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              height: appBarHeight,
              child: Row(
                children: [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (value) async {
                          users = await firestore.getUserByUserName();
                          setState(() {
                            users.forEach((element) {
                              filteredusers = users
                                  .where((element) => element
                                      .data()["name"]
                                      .toString()
                                      .toLowerCase()
                                      .contains(value))
                                  .toList();
                            });
                          });
                        },
                        decoration: InputDecoration(
                            hintText: 'User Name',
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
              itemBuilder: (context, index) => SearchTile(
                email: filteredusers[index].data()["email"],
                username: filteredusers[index].data()["name"],
                photoUrl: filteredusers[index].data()["photo"],
              ),
            ))
          ],
        ),
      ),
    );
  }
}