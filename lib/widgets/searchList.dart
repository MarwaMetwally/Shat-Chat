import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final String username;
  final String email;
  final String photoUrl;
  SearchTile({this.email, this.username, this.photoUrl});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        //    padding: EdgeInsets.all(10),
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
                          : NetworkImage(
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU'))),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(username), Text(email)],
            ),
            FlatButton(
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                onPressed: () {},
                child: Text(
                  'Message',
                  style: TextStyle(color: Colors.black),
                )),
          ],
        ),
      ),
    );
  }
}
