import 'package:flutter/material.dart';
import 'package:shatchat/screens/signin.dart';
import 'package:shatchat/screens/signup.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void togglescreen() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn ? SignIn(togglescreen) : SignUp(togglescreen);
  }
}
