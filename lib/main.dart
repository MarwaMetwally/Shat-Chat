import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:shatchat/screens/signin.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shatchat/screens/chatScreen.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shat chat',
      theme: ThemeData(
        primaryColor: Colors.grey[600],
        accentColor: Color(0xff5ad1a4),

        //primarySwatch: Color(0xff5ad1a4),),
      ),
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 5,
      navigateAfterSeconds: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ChatScreen();
          } else {
            return SignIn();
          }
        },
      ),
      loadingText: new Text(
        'Welcome In shat chat',
        style: new TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27.0),
      ),
      // title: new Text(
      //   'Welcome In shat chat',
      //   style: new TextStyle(
      //       color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27.0),
      // ),
      image: new Image.asset('assets/images/chatLogo.png'),
      imageBackground: AssetImage('assets/images/background.jpg'),
      // backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 80.0,
    );
  }
}
