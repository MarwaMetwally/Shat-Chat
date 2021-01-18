import 'package:flutter/material.dart';
import 'package:shatchat/helper/authenticate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:shatchat/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shatchat/screens/chatScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    FireStoreMethos store = new FireStoreMethos();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shat chat',
      theme: ThemeData(
        primaryColor: Colors.grey[600],
        accentColor: Color(0xff5ad1a4),

        //primarySwatch: Color(0xff5ad1a4),),
      ),
      // home: Search(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return FutureBuilder(
              future: store.getUserPhoto(FirebaseAuth.instance.currentUser.uid),
              builder: (context, snapshot) {
                return ChatScreen(snapshot.data != null
                    ? snapshot.data
                    : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdMCPi6SVnch4j_K57TF_XBbFmYuPGaMzOPQ&usqp=CAU');
              },
            );
          } else {
            return Authenticate();
          }
        },
      ),
    );
  }
}
