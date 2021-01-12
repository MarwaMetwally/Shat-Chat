import 'package:flutter/material.dart';
import 'package:shatchat/helper/authenticate.dart';

import 'screens/chatScreen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shat chat',
      theme: ThemeData(
        primaryColor: Colors.grey,
        accentColor: Color(0xff5ad1a4),

        //primarySwatch: Color(0xff5ad1a4),),
      ),
      // home: Search(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ChatScreen();
          } else {
            return Authenticate();
          }
        },
      ),
    );
  }
}
