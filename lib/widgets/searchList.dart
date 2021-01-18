import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final String username;
  Function onPressed;
  final String photoUrl;
  SearchTile({this.username, this.photoUrl, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                children: [Text(username)],
              ),
              FlatButton(
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  onPressed: onPressed,
                  child: Text(
                    'Message',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
